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
	@IBOutlet weak var stayLoggedInSwitch: UISwitch!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.isModalInPresentation = true
		
		employeeIDField.layer.borderWidth = 2.5
		passwordField.layer.borderWidth = 2.5
		employeeIDField.layer.borderColor = UIColor.clear.cgColor
		passwordField.layer.borderColor = UIColor.clear.cgColor
		
		let defaults = UserDefaults.standard
		stayLoggedInSwitch.setOn(defaults.bool(forKey: "stayLoggedIn"), animated: false)
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
					
					let defaults = UserDefaults.standard
					
					if (stayLoggedInSwitch.isOn) {
						defaults.set(employeeIDField.text, forKey: "savedEmployeeID")
						defaults.set(passwordField.text, forKey: "savedPassword")
						defaults.set(stayLoggedInSwitch.isOn, forKey: "stayLoggedIn")
					}
					
					NotificationCenter.default.post(name: .changeUser, object: nil)
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
	
	@IBAction func toggleStayLoggedIn(_ sender: Any) {
		
	}
}
