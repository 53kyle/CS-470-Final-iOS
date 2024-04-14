//
//  DateHelper.swift
//  CS-470-Final-iOS
//
//  Created by Kyle Pallo on 4/13/24.
//

import Foundation

func weekdayToString(weekday: Int) -> String {
	switch weekday - 1 {
	case 0:
		return "Sunday"
	case 1:
		return "Monday"
	case 2:
		return "Tuesday"
	case 3:
		return "Wednesday"
	case 4:
		return "Thursday"
	case 5:
		return "Friday"
	case 6:
		return "Saturday"
	default:
		return ""
	}
}

func monthToString(month: Int) -> String {
	switch month {
	case 1:
		return "January"
	case 2:
		return "February"
	case 3:
		return "March"
	case 4:
		return "April"
	case 5:
		return "May"
	case 6:
		return "June"
	case 7:
		return "July"
	case 8:
		return "August"
	case 9:
		return "September"
	case 10:
		return "October"
	case 11:
		return "November"
	case 12:
		return "December"
	default:
		return ""
	}
}

extension Date {
	func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
		 let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
		 return addingTimeInterval(delta)
	}
	
	func startOfMonth() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
	}
}
