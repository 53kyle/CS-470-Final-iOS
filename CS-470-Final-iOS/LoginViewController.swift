//
//  LoginViewController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/8/24.
//

import UIKit

class LoginViewController: UIViewController {
	@IBOutlet weak var employeeIDField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.isModalInPresentation = true
		
		employeeIDField.layer.borderWidth = 2.5
		passwordField.layer.borderWidth = 2.5
		employeeIDField.layer.borderColor = UIColor.clear.cgColor
		passwordField.layer.borderColor = UIColor.clear.cgColor
        // Do any additional setup after loading the view.
    }
    
	@IBAction func logInPress(_ sender: Any) {
		Task { @MainActor in
			let success = await APIInterface.sharedInstance.getUserInfo(userID: Int(employeeIDField.text ?? "") ?? -1)
			if (success) {
				if (hashCode(str: passwordField.text ?? "") == APIInterface.sharedInstance.user.password_hash) {
					print("Login Successful")
					self.dismiss(animated: true)
					employeeIDField.layer.borderColor = UIColor.clear.cgColor
					passwordField.layer.borderColor = UIColor.clear.cgColor
					
					if await APIInterface.sharedInstance.getNextShiftForUser(userID: APIInterface.sharedInstance.user.employee_id) {
						NotificationCenter.default.post(name: .changeUser, object: nil)
					}
				}
				else {
					employeeIDField.layer.borderColor = UIColor.clear.cgColor
					passwordField.layer.borderColor = UIColor.red.cgColor
					print("Incorrect Password")
				}
			}
			else {
				employeeIDField.layer.borderColor = UIColor.red.cgColor
				passwordField.layer.borderColor = UIColor.red.cgColor
				print("User Not Found")
			}
		}
	}
	
	func hashCode(str: String) -> String {
		var hash: Int = 0
		
		for char in str {
			hash = (hash << 5) - hash + Int(char.asciiValue!)
			hash |= 0
		}
		
		return String(format:"%02x", hash)
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
