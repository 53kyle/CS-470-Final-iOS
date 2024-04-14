//
//  ScheduleTableViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/9/24.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
	var shifts = [ShiftModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
		
		Task { @MainActor in
			self.shifts = await APIInterface.sharedInstance.getAllShiftsForUser(userID: APIInterface.sharedInstance.user.employee_id, startDate: "2024-04-01", endDate: "2069-12-31")
			
			self.tableView.reloadData()
		}
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ScheduleTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleTableViewCell
		
		let currentDate = Date()
		let startOfMonth = currentDate.startOfMonth()
		let startOfMonthAsSeconds = startOfMonth.timeIntervalSince1970
		let dateForRow = Date(timeIntervalSince1970: startOfMonthAsSeconds + Double(indexPath.row)*86400)
		let components = Calendar.current.dateComponents([.day, .year, .month, .weekday], from: dateForRow)
		
		let dateAsString = "\(components.year ?? 2024)-\(components.month ?? 0 < 10 ? "0" : "")\(components.month ?? 1)-\(components.day ?? 0 < 10 ? "0" : "")\(components.day ?? 1)T07:00:00.000Z"
		
		cell.dayLabel.text = "\(components.day ?? 0)"
		cell.monthLabel.text = monthToString(month: components.month ?? 0)
		cell.weekdayLabel.text = weekdayToString(weekday: components.weekday ?? 0)
		
		cell.timeLabel.text = "OFF"
		cell.timeLabel.textColor = .secondaryLabel
		cell.departmentLabel.text = ""
		cell.mealLabel.text = ""
		
		let todayShifts = shifts.filter {
			$0.date == dateAsString
		}
		
		if (todayShifts.count > 0) {
			let shift = todayShifts[0]
			
			let dateFormatter = DateFormatter()
			dateFormatter.timeZone = .gmt
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			
			let correctedStartTime = dateFormatter.date(from: shift.start_time)
			let correctedEndTime = dateFormatter.date(from: shift.end_time)
			let correctedMealStart = dateFormatter.date(from: shift.meal_start ?? "")
			let correctedMealEnd = dateFormatter.date(from: shift.meal_end ?? "")
			
			cell.timeLabel.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "")"
			
			cell.departmentLabel.text = shift.department.capitalized
			
			cell.mealLabel.text = shift.meal == 1 ? "Meal: \(correctedMealStart?.formatted(date: .omitted, time: .shortened) ?? "") - \(correctedMealEnd?.formatted(date: .omitted, time: .shortened) ?? "")" : "Meal: N/A"
			
			cell.timeLabel.textColor = .label
			cell.mealLabel.textColor = shift.meal == 1 ? .label : .secondaryLabel
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 103
	}
	
	@objc func changeUser(notification: NSNotification) {
		Task { @MainActor in
			self.shifts = await APIInterface.sharedInstance.getAllShiftsForUser(userID: APIInterface.sharedInstance.user.employee_id, startDate: "2024-04-01", endDate: "2024-04-30")
			
			self.tableView.reloadData()
		}
	}
}
