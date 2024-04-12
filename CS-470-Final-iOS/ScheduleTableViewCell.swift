//
//  ScheduleTableViewCell.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/9/24.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
	@IBOutlet weak var weekdayLabel: UILabel!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var departmentLabel: UILabel!
	@IBOutlet weak var mealLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
