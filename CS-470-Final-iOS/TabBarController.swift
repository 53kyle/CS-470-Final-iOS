//
//  TabBarController.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/8/24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		let defaults = UserDefaults.standard
		let savedEmployeeID = defaults.string(forKey: "savedEmployeeID")
		let savedPassword = defaults.string(forKey: "savedPassword")
		
		Task { @MainActor in
			let success = await APIInterface.sharedInstance.getUserInfo(userID: Int(savedEmployeeID ?? "-1") ?? -1)
			if (success) {
				if (hashCode(str: savedPassword ?? "") == APIInterface.sharedInstance.user.password_hash) {
					NotificationCenter.default.post(name: .changeUser, object: nil)
					print("Login Successful")
				}
				else {
					performSegue(withIdentifier: "showLogin", sender: self)
					print("Incorrect Password")
				}
			}
			else {
				performSegue(withIdentifier: "showLogin", sender: self)
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
