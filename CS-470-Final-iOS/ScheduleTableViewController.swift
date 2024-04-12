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
			self.shifts = await APIInterface.sharedInstance.getAllShiftsForUser(userID: APIInterface.sharedInstance.user.employee_id, startDate: "2024-04-01", endDate: "2024-04-30")
			
			self.tableView.reloadData()
		}

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return 30
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
		
		for shift in shifts {
			if (shift.date == dateAsString) {
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
		}

        // Configure the cell...

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 103
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
	
	@objc func changeUser(notification: NSNotification) {
		Task { @MainActor in
			self.shifts = await APIInterface.sharedInstance.getAllShiftsForUser(userID: APIInterface.sharedInstance.user.employee_id, startDate: "2024-04-01", endDate: "2024-04-30")
			
			self.tableView.reloadData()
		}
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
