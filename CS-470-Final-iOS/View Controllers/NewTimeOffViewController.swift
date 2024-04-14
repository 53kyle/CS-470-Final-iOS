//
//  NewTimeOffViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/13/24.
//

import UIKit

class NewTimeOffViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
	@IBOutlet weak var startDateField: UITextField!
	@IBOutlet weak var endDateField: UITextField!
	@IBOutlet weak var reasonField: UITextField!
	
	let startDatePicker = UIDatePicker()
	let endDatePicker = UIDatePicker()
	let reasonPicker = UIPickerView()
	
	var startDate = Date()
	var endDate = Date()
	
	var selectedReason = ""
	
	let reasons: [String] = ["Vacation", "Personal Day", "Sick Leave", "Family Emergency", "Doctor's Appointment", "Other"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationController!.isModalInPresentation = true

		startDateField.delegate = self
		endDateField.delegate = self
		reasonField.delegate = self
		
		startDatePicker.setDate(startDate, animated: false)
		startDatePicker.datePickerMode = .dateAndTime
		startDatePicker.minuteInterval = 5
		startDatePicker.addTarget(self, action: #selector(startDateChange(datePicker:)), for: UIControl.Event.valueChanged)
		startDatePicker.frame.size = CGSize(width: 0, height: 300)
		startDatePicker.preferredDatePickerStyle = .wheels
		startDateField.inputView = startDatePicker
		
		endDatePicker.setDate(endDate, animated: false)
		endDatePicker.datePickerMode = .dateAndTime
		endDatePicker.minuteInterval = 5
		endDatePicker.addTarget(self, action: #selector(endDateChange(datePicker:)), for: UIControl.Event.valueChanged)
		endDatePicker.frame.size = CGSize(width: 0, height: 300)
		endDatePicker.preferredDatePickerStyle = .wheels
		endDateField.inputView = endDatePicker
		
		reasonPicker.delegate = self
		reasonPicker.dataSource = self
		reasonPicker.reloadAllComponents()
		reasonField.inputView = reasonPicker
		
		selectedReason = reasons[0]
		reasonField.text = reasons[0]
		
		startDateField.layer.borderWidth = 2.5
		endDateField.layer.borderWidth = 2.5
		startDateField.layer.borderColor = UIColor.clear.cgColor
		endDateField.layer.borderColor = UIColor.clear.cgColor
    }
	
	@objc func startDateChange(datePicker: UIDatePicker) {
		if (datePicker.date.timeIntervalSince1970 > endDate.timeIntervalSince1970) {
			endDate = datePicker.date
			endDateField.text = "\(endDate.formatted(date: .abbreviated, time: .shortened))"
			endDatePicker.setDate(endDate, animated: false)
		}
		startDate = datePicker.date
		startDateField.text = "\(startDate.formatted(date: .abbreviated, time: .shortened))"
		startDateField.layer.borderColor = UIColor.clear.cgColor
	}
	
	@objc func endDateChange(datePicker: UIDatePicker) {
		if (startDate.timeIntervalSince1970 > datePicker.date.timeIntervalSince1970) {
			startDate = datePicker.date
			startDateField.text = "\(startDate.formatted(date: .abbreviated, time: .shortened))"
			startDatePicker.setDate(startDate, animated: true)
		}
		endDate = datePicker.date
		endDateField.text = "\(endDate.formatted(date: .abbreviated, time: .shortened))"
		endDateField.layer.borderColor = UIColor.clear.cgColor
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return reasons.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return reasons[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedReason = reasons[row]
		reasonField.text = reasons[row]
	}
	
	func validateInput() -> Bool {
		if (startDateField.text == "") {
			startDateField.layer.borderColor = UIColor.red.cgColor
			return false
		}
		else if (endDateField.text == "") {
			endDateField.layer.borderColor = UIColor.red.cgColor
			return false
		}
		return true
	}
    
	@IBAction func cancelPress(_ sender: Any) {
		self.dismiss(animated: true)
	}
	
	@IBAction func submitPress(_ sender: Any) {
		if (validateInput()) {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
			
			let startDateString = dateFormatter.string(from: startDate)
			let endDateString = dateFormatter.string(from: endDate)
			
			Task { @MainActor in
				if await APIInterface.sharedInstance.addTimeOff(userID: APIInterface.sharedInstance.user.employee_id, startTime: startDateString, endTime: endDateString, reason: selectedReason) {
					NotificationCenter.default.post(name: .changeUser, object: nil)
					self.dismiss(animated: true)
				}
			}
		}
	}
}
