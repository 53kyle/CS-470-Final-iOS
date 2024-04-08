//
//  APIInterface.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 3/28/24.
//

/*
	To print raw JSON:
 
	let utf8Text = String(data: data!, encoding: .utf8)
	print("Data: \(utf8Text)")
 */

import Foundation
import Alamofire

class APIInterface {
	static let sharedInstance = APIInterface()
	let baseURL = "http://blue.cs.sonoma.edu:8100/api/v1/"
	var user = EmployeeModel(employee_id: -1, first_name: "", last_name: "", permission: 0, password_hash: "", max_hours: 0);
	var nextShift = ShiftModel(shift_id: -1, department: "", employee_id: -1, start_time: "", end_time: "", meal: 0, meal_start: "", meal_end: "")
	
	func getUserInfo(userID: Int) async -> Bool {
		user = EmployeeModel(employee_id: -1, first_name: "", last_name: "", permission: 0, password_hash: "", max_hours: 0);
		let URL = baseURL + "login/\(userID)";
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode(UserModel.self, from: data!)
							self.user = jsonData.user
							
							continuation.resume()
						} catch {
							print(String(describing: error))
							continuation.resume()
						}
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
		
		return user.employee_id >= 0
	}
	
	func getNextShiftForUser(userID: Int) async -> Bool {
		nextShift = ShiftModel(shift_id: -1, department: "", employee_id: -1, start_time: "", end_time: "", meal: 0, meal_start: "", meal_end: "")
		let URL = baseURL + "shifts/employee/\(userID)/next";
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([ShiftModel].self, from: data!)
							
							if (jsonData.count > 0) {
								self.nextShift = jsonData[0]
							}
							
							continuation.resume()
						} catch {
							print(String(describing: error))
							continuation.resume()
						}
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
		
		return true
	}
}

struct UserModel: Codable {
	let user: EmployeeModel
}

struct EmployeeModel: Codable {
	let employee_id: Int
	let first_name: String
	let last_name: String
	let permission: Int
	let password_hash: String
	let max_hours: Int
}

struct ShiftModel: Codable {
	let shift_id: Int
	let department: String
	let employee_id: Int
	let start_time: String
	let end_time: String
	let meal: Int
	let meal_start: String
	let meal_end: String
}

extension Notification.Name {
	static let changeUser = Notification.Name("changeUser")
}
