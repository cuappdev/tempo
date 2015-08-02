//
//  NSDateFormatter+Shared.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/2/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

extension NSDateFormatter {
	static var dateFormatter: NSDateFormatter {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
		return formatter
	}
}