//
//  HomeViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/8/24.
//

import UIKit

class HomeViewController: UIViewController {
	@IBOutlet weak var employeeNameLabel: UILabel!
	@IBOutlet weak var employeeIDLabel: UILabel!
	@IBOutlet weak var nextShiftDateLabel: UILabel!
	@IBOutlet weak var nextShiftTimeLabel: UILabel!
	@IBOutlet weak var nextShiftWeekdayLabel: UILabel!
	@IBOutlet weak var nextShiftMonthLabel: UILabel!
	@IBOutlet weak var nextShiftDepartmentLabel: UILabel!
	@IBOutlet weak var nextShiftMealLabel: UILabel!
	@IBOutlet weak var nextShiftBG: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
		
		nextShiftBG.clipsToBounds = true
		nextShiftBG.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
	
	@objc func changeUser(notification: NSNotification) {
		employeeNameLabel.text = "\(APIInterface.sharedInstance.user.first_name) \(APIInterface.sharedInstance.user.last_name)"
		employeeIDLabel.text = "Employee ID: \(APIInterface.sharedInstance.user.employee_id)"
		
		Task { @MainActor in
			let nextShift = await APIInterface.sharedInstance.getNextShiftForUser(userID: APIInterface.sharedInstance.user.employee_id)
			
			if (nextShift.shift_id > -1) {
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = .gmt
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
				
				let correctedStartTime = dateFormatter.date(from: nextShift.start_time)
				let correctedEndTime = dateFormatter.date(from: nextShift.end_time)
				let correctedMealStart = dateFormatter.date(from: nextShift.meal_start ?? "")
				let correctedMealEnd = dateFormatter.date(from: nextShift.meal_end ?? "")
				
				nextShiftTimeLabel.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "")"
				
				nextShiftDepartmentLabel.text = nextShift.department.capitalized
				
				nextShiftMealLabel.text = nextShift.meal == 1 ? "Meal: \(correctedMealStart?.formatted(date: .omitted, time: .shortened) ?? "") - \(correctedMealEnd?.formatted(date: .omitted, time: .shortened) ?? "")" : "Meal: N/A"
				
				nextShiftMealLabel.textColor = nextShift.meal == 1 ? .label : .secondaryLabel
				
				let components = Calendar.current.dateComponents([.day, .year, .month, .weekday], from: correctedStartTime ?? Date())
				
				nextShiftDateLabel.text = "\(components.day ?? 0)"
				nextShiftMonthLabel.text = monthToString(month: components.month ?? 0)
				nextShiftWeekdayLabel.text = weekdayToString(weekday: components.weekday ?? 0)
			}
			else {
				nextShiftDateLabel.text = "No Upcoming Shifts"
				nextShiftTimeLabel.text = ""
				nextShiftWeekdayLabel.text = ""
				nextShiftMonthLabel.text = ""
				nextShiftDepartmentLabel.text = ""
				nextShiftMealLabel.text = ""
			}
		}
	}
	
	@IBAction func logOutPress(_ sender: Any) {
		let defaults = UserDefaults.standard
		defaults.set("", forKey: "savedEmployeeID")
		defaults.set("", forKey: "savedPassword")
	}
	
	func weekdayToString(weekday: Int) -> String {
		switch weekday - 1 {
		case 0:
			return "Sunday"
		case 1:
			return "Monday"
		case 2:
			return "Tuesday"
		case 3:
			return "Wednesday"
		case 4:
			return "Thursday"
		case 5:
			return "Friday"
		case 6:
			return "Saturday"
		default:
			return ""
		}
	}
	
	func monthToString(month: Int) -> String {
		switch month {
		case 1:
			return "January"
		case 2:
			return "February"
		case 3:
			return "March"
		case 4:
			return "April"
		case 5:
			return "May"
		case 6:
			return "June"
		case 7:
			return "July"
		case 8:
			return "August"
		case 9:
			return "September"
		case 10:
			return "October"
		case 11:
			return "November"
		case 12:
			return "December"
		default:
			return ""
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

extension Date {
	func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
		 let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
		 return addingTimeInterval(delta)
	}
	
	func startOfMonth() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
	}
}
