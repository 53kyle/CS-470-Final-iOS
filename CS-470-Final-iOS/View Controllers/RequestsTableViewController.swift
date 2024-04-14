//
//  RequestsTableViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/10/24.
//

import UIKit
 
class RequestsTableViewController: UITableViewController {
	var timeOffRequests = [TimeOffModel]()
	var availabilityRequests = [AvailabilityModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
		
		Task { @MainActor in
			self.timeOffRequests = await APIInterface.sharedInstance.getTimeOffRequestsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			self.availabilityRequests = await APIInterface.sharedInstance.getAvailabilityRequestsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			self.tableView.reloadData()
		}
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (section == 0) {
			return timeOffRequests.count
		}
		else if (section == 1) {
			return 8
		}
		return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> RequestTableViewCell {
		if (indexPath.section == 0) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "timeOffCell", for: indexPath) as! RequestTableViewCell

			let dateFormatter = DateFormatter()
			dateFormatter.timeZone = .gmt
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			
			let correctedStartTime = dateFormatter.date(from: timeOffRequests[indexPath.row].start_time)
			let correctedEndTime = dateFormatter.date(from: timeOffRequests[indexPath.row].end_time)
			
			if (correctedStartTime?.formatted(date: .complete, time: .omitted) ?? "" != correctedEndTime?.formatted(date: .complete, time: .omitted) ?? "") {
				cell.datesLabel.text = "\(correctedStartTime?.formatted(date: .abbreviated, time: .omitted) ?? "") - \(correctedEndTime?.formatted(date: .abbreviated, time: .omitted) ?? "")"
			}
			else {
				cell.datesLabel.text = "\(correctedStartTime?.formatted(date: .abbreviated, time: .omitted) ?? "")"
			}
			
			cell.pendingLabel.text = timeOffRequests[indexPath.row].status
			
			if (timeOffRequests[indexPath.row].status == "Pending") {
				cell.pendingLabel.textColor = .systemYellow
			}
			else if (timeOffRequests[indexPath.row].status == "Approved") {
				cell.pendingLabel.textColor = .systemGreen
			}
			else if (timeOffRequests[indexPath.row].status == "Denied") {
				cell.pendingLabel.textColor = .systemRed
			}
			else {
				cell.pendingLabel.textColor = .label
			}
			
			cell.reasonLabel.text = timeOffRequests[indexPath.row].reason

			return cell
		}
		else {
			if (indexPath.row == 0) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "maxHoursCell", for: indexPath) as! RequestTableViewCell
				
				cell.maxHoursLabel.text = "Max Hours: \(APIInterface.sharedInstance.user.max_hours)"
				
				return cell
			}
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "availabilityCell", for: indexPath) as! RequestTableViewCell
			
			cell.weekdayLabel.text = weekdayToString(weekday: indexPath.row)
			
			let availabilityRequestsForRow = availabilityRequests.filter {
				$0.day_of_week == weekdayToString(weekday: indexPath.row)
			}
			
			if (availabilityRequestsForRow.count > 0) {
				let currentAvailabilityRequests = availabilityRequestsForRow.filter {
					$0.status == "Approved"
				}
				let pendingAvailabilityRequests = availabilityRequestsForRow.filter {
					$0.status == "Pending"
				}
				
				if (currentAvailabilityRequests.count > 0) {
					for i in 0...currentAvailabilityRequests.count - 1 {
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "HH:mm:ss"
						
						if (i == 0) {
							let correctedStartTime = dateFormatter.date(from: currentAvailabilityRequests[0].start_time)
							let correctedEndTime = dateFormatter.date(from: currentAvailabilityRequests[0].end_time)
							cell.current1Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
						else if (i == 1) {
							let correctedStartTime = dateFormatter.date(from: currentAvailabilityRequests[1].start_time)
							let correctedEndTime = dateFormatter.date(from: currentAvailabilityRequests[1].end_time)
							cell.current2Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
						else if (i == 2) {
							let correctedStartTime = dateFormatter.date(from: currentAvailabilityRequests[2].start_time)
							let correctedEndTime = dateFormatter.date(from: currentAvailabilityRequests[2].end_time)
							cell.current3Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
					}
				}
				else {
					cell.current1Label.text = "OFF"
				}
				
				if (pendingAvailabilityRequests.count > 0) {
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "HH:mm:ss"
					
					for i in 0...pendingAvailabilityRequests.count - 1 {
						if (i == 0) {
							let correctedStartTime = dateFormatter.date(from: pendingAvailabilityRequests[0].start_time)
							let correctedEndTime = dateFormatter.date(from: pendingAvailabilityRequests[0].end_time)
							cell.pending1Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
						else if (i == 1) {
							let correctedStartTime = dateFormatter.date(from: pendingAvailabilityRequests[1].start_time)
							let correctedEndTime = dateFormatter.date(from: pendingAvailabilityRequests[1].end_time)
							cell.pending2Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
						else if (i == 2) {
							let correctedStartTime = dateFormatter.date(from: pendingAvailabilityRequests[2].start_time)
							let correctedEndTime = dateFormatter.date(from: pendingAvailabilityRequests[2].end_time)
							cell.pending3Label.text = "\(correctedStartTime?.formatted(date: .omitted, time: .shortened) ?? "ANY") - \(correctedEndTime?.formatted(date: .omitted, time: .shortened) ?? "ANY")"
						}
					}
				}
				else {
					cell.pending1Label.text = "N/A"
				}
			}
			else {
				cell.current1Label.text = "OFF"
				cell.pending1Label.text = "N/A"
			}
			
			return cell
		}
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath.section == 0) {
			return 103
		}
		else {
			if (indexPath.row == 0) {
				return 53
			}
			return 156
		}
	}
	
	@objc func changeUser(notification: NSNotification) {
		Task { @MainActor in
			self.timeOffRequests = await APIInterface.sharedInstance.getTimeOffRequestsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			
			self.tableView.reloadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (section == 0) {
			return "Time Off"
		}
		else if (section == 1) {
			return "Availability"
		}
		return ""
	}
}
