//
//  UIColor+Shared.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/26/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

extension UIColor {
	@nonobjc static let iceDarkRed = UIColor(red: 154/255.0, green: 57/255.0, blue: 54/255.0, alpha: 1.0)
	@nonobjc static let iceDarkGreen = UIColor(red: 20/255.0, green: 61/255.0, blue: 54/255.0, alpha: 1.0)
	@nonobjc static let iceDarkGray = UIColor(red: 35/255.0, green: 36/255.0, blue: 39/255.0, alpha: 1.0)
	@nonobjc static let iceLightGray = UIColor(red: 44/255.0, green: 45/255.0, blue: 48/255.0, alpha: 1.0)
	
	@nonobjc static let tempoUltraLightRed = UIColor.colorFromCode(0xA26660)
	@nonobjc static let tempoLightRed = UIColor.colorFromCode(0xB04B40)
	@nonobjc static let tempoDarkRed = UIColor.colorFromCode(0x8B4038)
	@nonobjc static let tempoLightGray = UIColor.colorFromCode(0x2C2D30)
	@nonobjc static let tempoDarkGray = UIColor.colorFromCode(0x232427)
	@nonobjc static let separatorGray = UIColor.colorFromCode(0x28282B)
	@nonobjc static let descriptionLightGray = UIColor.colorFromCode(0xC5B7B6)
	@nonobjc static let offWhite = UIColor.colorFromCode(0xC0C0C1)
	
	public static func colorFromCode(code: Int) -> UIColor {
		let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
		let green = CGFloat(((code & 0xFF00) >> 8)) / 255
		let blue = CGFloat((code & 0xFF)) / 255
		
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}