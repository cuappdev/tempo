//
//  NSDateFormatter+Shared.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/2/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension DateFormatter {
	
	@nonobjc static let parsingDateFormatter: DateFormatter = {
		$0.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
		$0.timeZone = TimeZone(secondsFromGMT: 0)
		$0.locale = Locale(identifier: "en_US")
		return $0
	}(DateFormatter())
	
	@nonobjc static let simpleDateFormatter: DateFormatter = {
		$0.dateFormat = "M.dd.YY"
		return $0
	}(DateFormatter())
	
	@nonobjc static let yearMonthDayFormatter: DateFormatter = {
		$0.dateFormat = "yyyy-MM-dd"
		$0.locale = Locale(identifier: "en_US_POSIX")
		return $0
	}(DateFormatter())
	
	@nonobjc static let slashYearMonthDayFormatter: DateFormatter = {
		$0.dateFormat = "yyyy/MM/dd"
		$0.locale = Locale(identifier: "en_US_POSIX")
		return $0
	}(DateFormatter())
	
	@nonobjc static let monthFormatter: DateFormatter = {
		$0.dateFormat = "MMM"
		return $0
	}(DateFormatter())
	
	@nonobjc static let postHistoryDateFormatter: DateFormatter = {
		$0.dateFormat = "MMM d, yyyy"
		$0.locale = Locale(identifier: "en_US_POSIX")
		return $0
	}(DateFormatter())
	
}
