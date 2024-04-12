//
//  RequestsTableViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/10/24.
//

import UIKit
 
class RequestsTableViewController: UITableViewController {
	var timeOffRequests = [TimeOffModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
		
		Task { @MainActor in
			self.timeOffRequests = await APIInterface.sharedInstance.getTimeOffRequestsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if (section == 0) {
			return timeOffRequests.count
		}
		else if (section == 1) {
			return 0
		}
		return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TimeOffTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeOffCell", for: indexPath) as! TimeOffTableViewCell

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
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 103
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
