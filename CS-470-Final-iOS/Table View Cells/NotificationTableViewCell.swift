//
//  NotificationsTableViewCell.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/14/24.
//

import UIKit
 
class NotificationTableViewCell: UITableViewCell {
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var unreadImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
