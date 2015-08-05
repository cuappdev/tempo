//
//  NSDateExtension.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

private func HipCalendarDate(components: NSDateComponents) -> NSDate {
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
    
    private func HipCalendarDateComponents(date: NSDate) -> NSDateComponents {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        return calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Day], fromDate:self)
    }
    
    func components() -> NSDateComponents {
        return HipCalendarDateComponents(self)
    }
    
    func month() -> Int {
        let components : NSDateComponents = HipCalendarDateComponents(self)
        return components.month
    }
    
    func day() -> Int {
        let components : NSDateComponents = HipCalendarDateComponents(self)
        return components.day
    }
    
    func year() -> Int {
        let components : NSDateComponents = HipCalendarDateComponents(self)
        return components.year
    }
    
    func firstDayOfMonth() -> NSDate {
        let components : NSDateComponents = HipCalendarDateComponents(self)
        components.day = 1
        return HipCalendarDate(components)
    }
    
    func lastDayOfMonth() -> NSDate {
        let components : NSDateComponents = HipCalendarDateComponents(self)
        components.month++
        components.day = 0
        return HipCalendarDate(components)
    }
    
    func numDaysInMonth() -> Int {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let firstDay : NSDate = self.firstDayOfMonth()
        let lastDay : NSDate = self.lastDayOfMonth()
        
        let components : NSDateComponents = calendar.components(NSCalendarUnit.Day, fromDate: firstDay, toDate: lastDay, options: NSCalendarOptions(rawValue: 0))
        
        if (isCurrentMonth(firstDay)) {
            components.day = NSDate().day()
            return components.day
        }
        
        return components.day + 1
    }
    
    func numberOfMonths(endDate: NSDate) -> Int {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let components : NSDateComponents = calendar.components(NSCalendarUnit.Month, fromDate:self, toDate:endDate, options: NSCalendarOptions(rawValue: 0))
        return components.month + 1
    }
    
    func dateByAddingMonths(months: Int) -> NSDate {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let components : NSDateComponents = NSDateComponents()
        components.month = months
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func numDaysUntilEndDate(endDate: NSDate) -> Int {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let components : NSDateComponents = calendar.components(NSCalendarUnit.Day, fromDate:self, toDate:endDate, options: NSCalendarOptions(rawValue: 0))
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
        return HipCalendarDate(components)
    }
    
}
