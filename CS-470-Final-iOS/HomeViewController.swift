//
//  HomeViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/8/24.
//

import UIKit

class HomeViewController: UIViewController {
	@IBOutlet weak var employeeNameLabel: UILabel!
	@IBOutlet weak var employeeIDLabel: UILabel!
	@IBOutlet weak var nextShiftDateLabel: UILabel!
	@IBOutlet weak var nextShiftTimeLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(changeUser(notification:)), name: .changeUser, object: nil)
        // Do any additional setup after loading the view.
    }
	
	@objc func changeUser(notification: NSNotification) {
		employeeNameLabel.text = "\(APIInterface.sharedInstance.user.first_name) \(APIInterface.sharedInstance.user.last_name)"
		employeeIDLabel.text = "Employee ID: \(APIInterface.sharedInstance.user.employee_id)"
		
		if (APIInterface.sharedInstance.nextShift.shift_id > -1) {
			nextShiftDateLabel.text = APIInterface.sharedInstance.nextShift.start_time
			nextShiftTimeLabel.text = APIInterface.sharedInstance.nextShift.end_time
		}
		else {
			nextShiftDateLabel.text = "N/A"
			nextShiftTimeLabel.text = "N/A"
		}
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
