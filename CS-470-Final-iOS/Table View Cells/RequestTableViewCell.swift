//
//  TimeOffTableViewCell.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/10/24.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
	@IBOutlet weak var datesLabel: UILabel!
	@IBOutlet weak var reasonLabel: UILabel!
	@IBOutlet weak var pendingLabel: UILabel!
	
	@IBOutlet weak var weekdayLabel: UILabel!
	@IBOutlet weak var current1Label: UILabel!
	@IBOutlet weak var current2Label: UILabel!
	@IBOutlet weak var current3Label: UILabel!
	@IBOutlet weak var pending1Label: UILabel!
	@IBOutlet weak var pending2Label: UILabel!
	@IBOutlet weak var pending3Label: UILabel!
	
	@IBOutlet weak var maxHoursLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
