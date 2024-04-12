//
//  TimeOffTableViewCell.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/10/24.
//

import UIKit

class TimeOffTableViewCell: UITableViewCell {
	@IBOutlet weak var datesLabel: UILabel!
	@IBOutlet weak var reasonLabel: UILabel!
	@IBOutlet weak var pendingLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
