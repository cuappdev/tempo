//
//  NSDateExtension.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

private func calendarDate(components: NSDateComponents) -> NSDate {
	let calendar : NSCalendar = NSCalendar.currentCalendar()
	return calendar.dateFromComponents(components)!
}

extension NSDate {
    
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:date!)
    }
	
    private func calendarDateComponents() -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components([.Year, .Month, .WeekOfYear, .Day], fromDate:self)
    }
    
    func components() -> NSDateComponents {
        return calendarDateComponents()
    }
    
    func month() -> Int {
        return calendarDateComponents().month
    }
    
    func day() -> Int {
        return calendarDateComponents().day
    }
    
    func year() -> Int {
        return calendarDateComponents().year
    }
    
    func firstDayOfMonth() -> NSDate {
        let components = calendarDateComponents()
        components.day = 1
        return calendarDate(components)
    }
    
    func lastDayOfMonth() -> NSDate {
        let components = calendarDateComponents()
        components.month++
        components.day = 0
        return calendarDate(components)
    }
    
    func numDaysInMonth() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let firstDay = self.firstDayOfMonth()
        let lastDay = self.lastDayOfMonth()
        
        let components = calendar.components(.Day, fromDate: firstDay, toDate: lastDay, options: NSCalendarOptions(rawValue: 0))
        
        if isCurrentMonth(firstDay) {
            components.day = NSDate().day()
            return components.day
        }
        
        return components.day + 1
    }
    
    func numberOfMonths(endDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Month, fromDate:self, toDate:endDate, options: NSCalendarOptions(rawValue: 0))
        return components.month + 1
    }
    
    func dateByAddingMonths(months: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.month = months
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func numDaysUntilEndDate(endDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate:self, toDate:endDate, options: NSCalendarOptions(rawValue: 0))
        return components.day + 1
    }
    
    func isCurrentMonth(date: NSDate) -> Bool {
        return (date.month() == NSDate().month() && date.year() == NSDate().year())
    }
    
    func timeDescription(format: String) -> String {
        let formatter: NSDateFormatter =  NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    class func dateFromComponents(components: NSDateComponents) -> NSDate {
        return calendarDate(components)
    }
    
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
	return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
	return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
