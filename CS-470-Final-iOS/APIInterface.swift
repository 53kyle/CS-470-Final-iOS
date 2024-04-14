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
	
	func getNextShiftForUser(userID: Int) async -> ShiftModel {
		var returnShift = ShiftModel(shift_id: -1, department: "", employee_id: -1, start_time: "", end_time: "", meal: 0, meal_start: "", meal_end: "", date: "", employee_fname: "", employee_lname: "")
		let URL = baseURL + "shifts/employee/\(userID)/next"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([ShiftModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnShift = jsonData[0]
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
		
		return returnShift
	}
	
	func getTodaysShiftForUser(userID: Int) async -> ShiftModel {
		var returnShift = ShiftModel(shift_id: -1, department: "", employee_id: -1, start_time: "", end_time: "", meal: 0, meal_start: "", meal_end: "", date: "", employee_fname: "", employee_lname: "")
		let URL = baseURL + "shifts/employee/\(userID)/today"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([ShiftModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnShift = jsonData[0]
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
		
		return returnShift
	}
	
	func getLastPunchForUser(userID: Int) async -> PunchModel {
		var returnPunch = PunchModel(employee_id: -1, punchin: "", approved: 0, pending: 0, punch_type: "")
		let URL = baseURL + "punchin/last-punch/\(userID)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([PunchModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnPunch = jsonData[0]
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
		
		return returnPunch
	}
	
	func getAllShiftsForUser(userID: Int, startDate: String, endDate: String) async -> [ShiftModel] {
		var returnShifts = [ShiftModel]()
		let URL = baseURL + "shifts/employee/\(userID)/\(startDate)/\(endDate)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([ShiftModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnShifts = jsonData
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
		
		return returnShifts
	}
	
	func getTimeOffRequestsForUser(userID: Int) async -> [TimeOffModel] {
		var returnTimeOffRequests = [TimeOffModel]()
		let URL = baseURL + "employees/requests/time-off/\(userID)/"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([TimeOffModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnTimeOffRequests = jsonData
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
		
		return returnTimeOffRequests
	}
	
	func getAvailabilityRequestsForUser(userID: Int) async -> [AvailabilityModel] {
		var returnAvailabilityRequests = [AvailabilityModel]()
		let URL = baseURL + "employees/requests/availability/\(userID)/"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						do {
							let jsonData = try JSONDecoder().decode([AvailabilityModel].self, from: data!)
							
							if (jsonData.count > 0) {
								returnAvailabilityRequests = jsonData
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
		
		return returnAvailabilityRequests
	}
	
	func startShift(userID: Int, approved: Bool) async {
		let URL = baseURL + "punchin/start-shift/\(userID)/\(approved ? 1 : 0)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						print(String(describing: data))
						continuation.resume()
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
	}
	
	func endShift(userID: Int, approved: Bool) async {
		let URL = baseURL + "punchin/end-shift/\(userID)/\(approved ? 1 : 0)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						print(String(describing: data))
						continuation.resume()
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
	}
	
	func startMeal(userID: Int, approved: Bool) async {
		let URL = baseURL + "punchin/start-meal/\(userID)/\(approved ? 1 : 0)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						print(String(describing: data))
						continuation.resume()
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
	}
	
	func endMeal(userID: Int, approved: Bool) async {
		let URL = baseURL + "punchin/end-meal/\(userID)/\(approved ? 1 : 0)"
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						print(String(describing: data))
						continuation.resume()
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
	}
	
	func addTimeOff(userID: Int, startTime: String, endTime: String, reason: String) async -> Bool {
		let URL = baseURL + "employees/requests/add-time-off/\(userID)/\(startTime)/\(endTime)/\(reason)"
		var success = false
		
		await withCheckedContinuation { continuation in
			AF.request(URL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { resp in
				switch resp.result {
					case .success(let data):
						print(String(describing: data))
						success = true
						continuation.resume()
					case .failure(let error):
						print(String(describing: error))
						continuation.resume()
				}
			}
		}
		
		return success
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
	let meal_start: String?
	let meal_end: String?
	let date: String?
	let employee_fname: String?
	let employee_lname: String?
}

struct TimeOffModel: Codable {
	let employee_id: Int
	let start_time: String
	let end_time: String
	let reason: String
	let status: String
}

struct AvailabilityModel: Codable {
	let employee_id: Int
	let day_of_week: String
	let start_time: String
	let end_time: String
	let status: String
}

struct PunchModel: Codable {
	let employee_id: Int
	let punchin: String
	let approved: Int
	let pending: Int
	let punch_type: String
}

extension Notification.Name {
	static let changeUser = Notification.Name("changeUser")
}
