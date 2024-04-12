//
//  TimeClockViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/10/24.
//

import UIKit
import LocalAuthentication

class TimeClockViewController: UIViewController {
	@IBOutlet weak var punchesBG: UIView!
	@IBOutlet weak var lastPunchLabel: UILabel!
	@IBOutlet weak var nextPunchLabel: UILabel!
	
	var nowDate = Date()
	var nextDate = Date(timeIntervalSince1970: 0)
	var nextType = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)

		punchesBG.clipsToBounds = true
		punchesBG.layer.cornerRadius = 10
		
		Task { @MainActor in
			await refreshPunches()
		}
        // Do any additional setup after loading the view.
    }
	
	@objc func changeUser(notification: NSNotification) {
		Task { @MainActor in
			await refreshPunches()
		}
	}
	
	func refreshPunches() async {
		let lastPunch = await APIInterface.sharedInstance.getLastPunchForUser(userID: APIInterface.sharedInstance.user.employee_id)
		let nextShift = await APIInterface.sharedInstance.getNextShiftForUser(userID: APIInterface.sharedInstance.user.employee_id)
		let todaysShift = await APIInterface.sharedInstance.getTodaysShiftForUser(userID: APIInterface.sharedInstance.user.employee_id)
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .gmt
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		
		nowDate = Date()
		
		if (todaysShift.shift_id >= 0) {
			if (lastPunch.punch_type.capitalized == "Start Shift") {
				if (todaysShift.meal == 1) {
					nextDate = dateFormatter.date(from: todaysShift.meal_start ?? "") ?? Date()
					nextType = "Start Meal"
					nextPunchLabel.text = "Start Meal: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
				}
				else {
					nextDate = dateFormatter.date(from: todaysShift.end_time) ?? Date()
					nextType = "End Shift"
					nextPunchLabel.text = "End Shift: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
				}
			}
			else if (lastPunch.punch_type.capitalized == "Start Meal") {
				nextDate = dateFormatter.date(from: todaysShift.meal_end ?? "") ?? Date()
				nextType = "End Meal"
				nextPunchLabel.text = "End Meal: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
			}
			else if (lastPunch.punch_type.capitalized == "End Meal") {
				nextDate = dateFormatter.date(from: todaysShift.end_time) ?? Date()
				nextType = "End Shift"
				nextPunchLabel.text = "End Shift: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
			}
			else if (lastPunch.punch_type.capitalized == "End Shift") {
				let correctedLastPunch = dateFormatter.date(from: lastPunch.punchin)
				
				if (nowDate.formatted(date: .abbreviated, time: .omitted) == correctedLastPunch?.formatted(date: .abbreviated, time: .omitted) ?? "") {
					if (nextShift.shift_id >= 0) {
						nextDate = dateFormatter.date(from: nextShift.start_time) ?? Date()
						nextType = "Start Shift"
						
						if (nowDate.formatted(date: .abbreviated, time: .omitted) == nextDate.formatted(date: .abbreviated, time: .omitted)) {
							nextType = "N/A"
							nextPunchLabel.text = ""
							// get next, next shift???
						}
						else {
							nextPunchLabel.text = "Start Shift: \(nextDate.formatted(date: .abbreviated, time: .omitted)) at \(nextDate.formatted(date: .omitted, time: .shortened))"
						}
					}
					else {
						nextType = "N/A"
						nextPunchLabel.text = "No Upcoming Shifts"
					}
				}
				else {
					nextDate = dateFormatter.date(from: todaysShift.start_time) ?? Date()
					nextType = "Start Shift"
					nextPunchLabel.text = "Start Shift: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
				}
			}
			else {
				nextDate = dateFormatter.date(from: todaysShift.start_time) ?? Date()
				nextType = "Start Shift"
				nextPunchLabel.text = "Start Shift: Today at \(nextDate.formatted(date: .omitted, time: .shortened))"
			}
		}
		else if (nextShift.shift_id >= 0) {
			nextDate = dateFormatter.date(from: nextShift.start_time) ?? Date()
			nextType = "Start Shift"
			nextPunchLabel.text = "Start Shift: \(nextDate.formatted(date: .abbreviated, time: .omitted)) at \(nextDate.formatted(date: .omitted, time: .shortened))"
		}
		else {
			nextType = "N/A"
			nextPunchLabel.text = "No Upcoming Shifts"
		}
		
		refreshPunchUrgency()
		
		if (lastPunch.employee_id >= 0) {
			let correctedLastPunch = dateFormatter.date(from: lastPunch.punchin) ?? Date()
			
			if (correctedLastPunch.formatted(date: .abbreviated, time: .omitted) == nowDate.formatted(date: .abbreviated, time: .omitted)) {
				lastPunchLabel.text = "\(lastPunch.punch_type.capitalized): Today at \(correctedLastPunch.formatted(date: .omitted, time: .shortened))\(lastPunch.approved == 1 ? "" : "*")"
			}
			else {
				lastPunchLabel.text = "\(lastPunch.punch_type.capitalized): \(correctedLastPunch.formatted(date: .numeric, time: .omitted)) at \(correctedLastPunch.formatted(date: .omitted, time: .shortened))\(lastPunch.approved == 1 ? "" : "*")"
			}
			
			lastPunchLabel.textColor = lastPunch.approved == 1 ? .label : .secondaryLabel
		}
	}
	
	func refreshPunchUrgency() {
		if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 - 300) {
			nextPunchLabel.textColor = .label
		}
		else if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 + 300) {
			nextPunchLabel.textColor = .systemYellow
		}
		else {
			nextPunchLabel.textColor = .systemRed
		}
	}
    
	@IBAction func startShiftPress(_ sender: Any) {
		nowDate = Date()
		var denialMessage = ""
		var approved = false
		
		var context = LAContext()
		
		var error: NSError?
		
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			print(error?.localizedDescription ?? "Can't evaluate policy")

			let alertController = UIAlertController(title: "Punch Denied", message: "Authentication is required for recording punches.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
				return
			}
			
			alertController.addAction(cancelAction)
			
			present(alertController, animated: true)
			
			return
		}
		
		Task {
			do {
				try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to record a punch.")
				
				if (nextType == "N/A") {
					denialMessage = "No punches expected for today."
				}
				else if (nextType != "Start Shift") {
					denialMessage = "Your next expected punch is \(nextType)."
				}
				else if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 - 300) {
					denialMessage = "Too early."
				}
				else if (nowDate.timeIntervalSince1970 > nextDate.timeIntervalSince1970 + 300) {
					denialMessage = "Too late."
				}
				else {
					approved = true
				}
				
				if (!approved) {
					let alertController = UIAlertController(title: "Punch Denied", message: denialMessage, preferredStyle: .alert)
					
					let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
						return
					}
					
					alertController.addAction(cancelAction)
					
					let forcePunchAction = UIAlertAction(title: "Request Approval", style: .destructive) { (action) in
						Task { @MainActor in
							await APIInterface.sharedInstance.startShift(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
							await self.refreshPunches()
						}
					}
					
					alertController.addAction(forcePunchAction)
					
					present(alertController, animated: true)
				}
				else {
					Task { @MainActor in
						await APIInterface.sharedInstance.startShift(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
						await refreshPunches()
					}
				}
				
			} catch let error {
				print(error.localizedDescription)

				let alertController = UIAlertController(title: "Punch Denied", message: "Authentication failed.", preferredStyle: .alert)
				
				let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
					return
				}
				
				alertController.addAction(cancelAction)
				
				present(alertController, animated: true)
				
				return
			}
		}
	}
	
	@IBAction func endShiftPress(_ sender: Any) {
		nowDate = Date()
		var denialMessage = ""
		var approved = false
		
		var context = LAContext()
		
		var error: NSError?
		
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			print(error?.localizedDescription ?? "Can't evaluate policy")

			let alertController = UIAlertController(title: "Punch Denied", message: "Authentication is required for recording punches.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
				return
			}
			
			alertController.addAction(cancelAction)
			
			present(alertController, animated: true)
			
			return
		}
		
		Task {
			do {
				try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to record a punch.")
				
				if (nextType == "N/A") {
					denialMessage = "No punches expected for today."
				}
				else if (nextType != "End Shift") {
					denialMessage = "Your next expected punch is \(nextType)."
				}
				else if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 - 300) {
					denialMessage = "Too early."
				}
				else if (nowDate.timeIntervalSince1970 > nextDate.timeIntervalSince1970 + 300) {
					denialMessage = "Too late."
				}
				else {
					approved = true
				}
				
				if (!approved) {
					let alertController = UIAlertController(title: "Punch Denied", message: denialMessage, preferredStyle: .alert)
					
					let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
						return
					}
					
					alertController.addAction(cancelAction)
					
					let forcePunchAction = UIAlertAction(title: "Request Approval", style: .destructive) { (action) in
						Task { @MainActor in
							await APIInterface.sharedInstance.endShift(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
							await self.refreshPunches()
						}
					}
					
					alertController.addAction(forcePunchAction)
					
					present(alertController, animated: true)
				}
				else {
					Task { @MainActor in
						await APIInterface.sharedInstance.endShift(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
						await refreshPunches()
					}
				}
				
			} catch let error {
				print(error.localizedDescription)

				let alertController = UIAlertController(title: "Punch Denied", message: "Authentication failed.", preferredStyle: .alert)
				
				let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
					return
				}
				
				alertController.addAction(cancelAction)
				
				present(alertController, animated: true)
				
				return
			}
		}
	}
	
	@IBAction func startMealPress(_ sender: Any) {
		nowDate = Date()
		var denialMessage = ""
		var approved = false
		
		var context = LAContext()
		
		var error: NSError?
		
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			print(error?.localizedDescription ?? "Can't evaluate policy")

			let alertController = UIAlertController(title: "Punch Denied", message: "Authentication is required for recording punches.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
				return
			}
			
			alertController.addAction(cancelAction)
			
			present(alertController, animated: true)
			
			return
		}
		
		Task {
			do {
				try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to record a punch.")
				
				if (nextType == "N/A") {
					denialMessage = "No punches expected for today."
				}
				else if (nextType != "Start Meal") {
					denialMessage = "Your next expected punch is \(nextType)."
				}
				else if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 - 300) {
					denialMessage = "Too early."
				}
				else if (nowDate.timeIntervalSince1970 > nextDate.timeIntervalSince1970 + 300) {
					denialMessage = "Too late."
				}
				else {
					approved = true
				}
				
				if (!approved) {
					let alertController = UIAlertController(title: "Punch Denied", message: denialMessage, preferredStyle: .alert)
					
					let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
						return
					}
					
					alertController.addAction(cancelAction)
					
					let forcePunchAction = UIAlertAction(title: "Request Approval", style: .destructive) { (action) in
						Task { @MainActor in
							await APIInterface.sharedInstance.startMeal(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
							await self.refreshPunches()
						}
					}
					
					alertController.addAction(forcePunchAction)
					
					present(alertController, animated: true)
				}
				else {
					Task { @MainActor in
						await APIInterface.sharedInstance.startMeal(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
						await refreshPunches()
					}
				}
				
			} catch let error {
				print(error.localizedDescription)

				let alertController = UIAlertController(title: "Punch Denied", message: "Authentication failed.", preferredStyle: .alert)
				
				let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
					return
				}
				
				alertController.addAction(cancelAction)
				
				present(alertController, animated: true)
				
				return
			}
		}
	}
	
	@IBAction func endMealPress(_ sender: Any) {
		nowDate = Date()
		var denialMessage = ""
		var approved = false
		
		var context = LAContext()
		
		var error: NSError?
		
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			print(error?.localizedDescription ?? "Can't evaluate policy")

			let alertController = UIAlertController(title: "Punch Denied", message: "Authentication is required for recording punches.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
				return
			}
			
			alertController.addAction(cancelAction)
			
			present(alertController, animated: true)
			
			return
		}
		
		Task {
			do {
				try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to record a punch.")
				
				if (nextType == "N/A") {
					denialMessage = "No punches expected for today."
				}
				else if (nextType != "End Meal") {
					denialMessage = "Your next expected punch is \(nextType)."
				}
				else if (nowDate.timeIntervalSince1970 < nextDate.timeIntervalSince1970 - 300) {
					denialMessage = "Too early."
				}
				else if (nowDate.timeIntervalSince1970 > nextDate.timeIntervalSince1970 + 300) {
					denialMessage = "Too late."
				}
				else {
					approved = true
				}
				
				if (!approved) {
					let alertController = UIAlertController(title: "Punch Denied", message: denialMessage, preferredStyle: .alert)
					
					let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
						return
					}
					
					alertController.addAction(cancelAction)
					
					let forcePunchAction = UIAlertAction(title: "Request Approval", style: .destructive) { (action) in
						Task { @MainActor in
							await APIInterface.sharedInstance.endMeal(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
							await self.refreshPunches()
						}
					}
					
					alertController.addAction(forcePunchAction)
					
					present(alertController, animated: true)
				}
				else {
					Task { @MainActor in
						await APIInterface.sharedInstance.endMeal(userID: APIInterface.sharedInstance.user.employee_id, approved: approved)
						await refreshPunches()
					}
				}
				
			} catch let error {
				print(error.localizedDescription)

				let alertController = UIAlertController(title: "Punch Denied", message: "Authentication failed.", preferredStyle: .alert)
				
				let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
					return
				}
				
				alertController.addAction(cancelAction)
				
				present(alertController, animated: true)
				
				return
			}
		}
	}
	
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
