//
//  NSDateFormatter+Shared.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/2/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension NSDateFormatter {
	
	@nonobjc static let parsingDateFormatter: NSDateFormatter = {
		$0.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
		$0.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		$0.locale = NSLocale(localeIdentifier: "en_US")
		return $0
	}(NSDateFormatter())
	
	@nonobjc static let simpleDateFormatter: NSDateFormatter = {
		$0.dateFormat = "M.dd.YY"
		return $0
	}(NSDateFormatter())
	
	@nonobjc static let yearMonthDayFormatter: NSDateFormatter = {
		$0.dateFormat = "yyyy-MM-dd"
		$0.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		return $0
	}(NSDateFormatter())
	
	@nonobjc static let monthFormatter: NSDateFormatter = {
		$0.dateFormat = "MMM"
		return $0
	}(NSDateFormatter())
}