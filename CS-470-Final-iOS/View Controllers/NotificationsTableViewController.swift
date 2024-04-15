//
//  NotificationsTableViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/14/24.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
	var notifications = [NotificationModel]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
    }
	
	override func viewDidAppear(_ animated: Bool) {		
		Task { @MainActor in
			self.notifications = await APIInterface.sharedInstance.getAllNotificationsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			
			self.tableView.reloadData()
			
			if await APIInterface.sharedInstance.setNotificationsReadForUser(userID: APIInterface.sharedInstance.user.employee_id) {
				NotificationCenter.default.post(name: .readNotifications, object: nil)
			}
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> NotificationTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .gmt
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		
		let correctedTime = dateFormatter.date(from: notifications[indexPath.row].time)
		
		cell.dateLabel.text = correctedTime?.formatted(date: .abbreviated, time: .shortened) ?? ""
		cell.messageLabel.text = notifications[indexPath.row].message
		cell.unreadImageView.isHidden = notifications[indexPath.row].unread == 1 ? false : true

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 130
	}
	
	@objc func changeUser(notification: NSNotification) {
		Task { @MainActor in
			self.notifications = await APIInterface.sharedInstance.getAllNotificationsForUser(userID: APIInterface.sharedInstance.user.employee_id)
			
			self.tableView.reloadData()
		}
	}
}
