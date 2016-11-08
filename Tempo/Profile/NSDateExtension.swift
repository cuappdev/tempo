//
//  NSDateExtension.swift
//  Tempo
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

private func calendarDate(_ components: DateComponents) -> Date {
	let calendar : Calendar = Calendar.current
	return calendar.date(from: components)!
}

extension Date {
    
	init(dateString: String) {
        let date = DateFormatter.yearMonthDayFormatter.date(from: dateString)
		self.init(timeInterval: 0, since: date!)
    }
	
    fileprivate func calendarDateComponents() -> DateComponents {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components([.year, .month, .weekOfYear, .day], from: self)
    }
    
    func components() -> DateComponents {
        return calendarDateComponents()
    }
    
    func month() -> Int {
        return calendarDateComponents().month!
    }
    
    func day() -> Int {
        return calendarDateComponents().day!
    }
    
    func year() -> Int {
        return calendarDateComponents().year!
    }
	
	func yearMonthDay() -> String {
		return "\(year())/\(month())/\(day())"
	}
    
    func firstDayOfMonth() -> Date {
        var components = calendarDateComponents()
        components.day = 1
        return calendarDate(components)
    }
    
    func lastDayOfMonth() -> Date {
        var components = calendarDateComponents()
		if let month = components.month {
			components.month = month + 1
		}
		components.day = 0
        return calendarDate(components)
    }
    
    func numDaysInMonth() -> Int {
        let calendar = Calendar.current
        let firstDay = firstDayOfMonth()
        let lastDay = lastDayOfMonth()
        
        var components = (calendar as NSCalendar).components(.day, from: firstDay, to: lastDay, options: NSCalendar.Options(rawValue: 0))
        
        if isCurrentMonth(firstDay) {
            components.day = Date().day()
            return components.day!
        }
        
        return components.day! + 1
    }
    
    func numberOfMonths(_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.month, from: self, to: endDate, options: NSCalendar.Options(rawValue: 0))
        return components.month! + 1
    }
    
    func dateByAddingMonths(_ months: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = months
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func numDaysUntilEndDate(_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self, to: endDate, options: NSCalendar.Options(rawValue: 0))
        return components.day! + 1
    }
    
    func isCurrentMonth(_ date: Date) -> Bool {
        return (date.month() == Date().month() && date.year() == Date().year())
    }
    
    static func dateFromComponents(_ components: DateComponents) -> Date {
        return calendarDate(components)
    }
    
}

public func ==(lhs: Date, rhs: Date) -> Bool {
	return lhs as AnyObject === rhs as AnyObject || lhs.compare(rhs) == .orderedSame
}

public func <(lhs: Date, rhs: Date) -> Bool {
	return lhs.compare(rhs) == .orderedAscending
}

