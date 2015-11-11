//
//  NSDateFormatter+Shared.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/2/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension NSDateFormatter {
	
	static var parsingDateFormatter: NSDateFormatter {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
		formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		formatter.locale = NSLocale(localeIdentifier: "en_US")
		return formatter
	}
	
	static var simpleDateFormatter: NSDateFormatter {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "M.dd.YY"
		return formatter
	}
	
	static var yearMonthDayFormatter: NSDateFormatter {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		return formatter
	}
	
	static var monthFormatter: NSDateFormatter {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "MMM"
		return formatter
	}
}