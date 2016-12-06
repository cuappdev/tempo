//
//  UIColor+Shared.swift
//  Tempo
//
//  Created by Manuela Rios on 4/26/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

extension UIColor {
	@nonobjc static let tempoOnboardingGray = UIColor.colorFromCode(0x292424)
	@nonobjc static let tempoRed = UIColor.colorFromCode(0xA23A40)
	@nonobjc static let tempoDarkRed = UIColor.colorFromCode(0xA23A40).withAlphaComponent(0.26)
	@nonobjc static let tempoLightGray = UIColor.colorFromCode(0x2C2D30)
	@nonobjc static let tempoGray = UIColor.colorFromCode(0xEAEAEA).withAlphaComponent(0.88)
	@nonobjc static let tempoDarkGray = UIColor.colorFromCode(0x232427)
	@nonobjc static let tempoSuperDarkGray = UIColor.colorFromCode(0x191A1D)
	@nonobjc static let separatorGray = UIColor.colorFromCode(0x28282B)
	@nonobjc static let descriptionLightGray = UIColor.colorFromCode(0xC5B7B6)
	@nonobjc static let offWhite = UIColor.colorFromCode(0xC0C0C1)
	@nonobjc static let facebookBlue = UIColor.colorFromCode(0x01457E)
	@nonobjc static let buttonGrey = UIColor.colorFromCode(0xF3F0F0).withAlphaComponent(0.88)
	@nonobjc static let buttonTransparentGrey = UIColor.colorFromCode(0xF3F0F0).withAlphaComponent(0.48)
	@nonobjc static let spotifyGreen = UIColor.colorFromCode(0x059952)
	@nonobjc static let usernameBGGrey = UIColor.colorFromCode(0xD8D8D8).withAlphaComponent(0.75)
	@nonobjc static let wrongRed = UIColor.colorFromCode(0xA32222)
	@nonobjc static let correctGreen = UIColor.colorFromCode(0x08673A)
	@nonobjc static let descriptionGrey = UIColor.colorFromCode(0x7A7676)
	@nonobjc static let backgroundDarkGrey = UIColor.colorFromCode(0x1C1D1E)
	@nonobjc static let revealShadowBlack = UIColor.colorFromCode(0x0E0C0C)
	@nonobjc static let unreadCellColor = UIColor.colorFromCode(0x2E2E30)
	@nonobjc static let readCellColor = UIColor.colorFromCode(0x1D1E1F)
	@nonobjc static let paleRed = UIColor.colorFromCode(0xBCAEAD)
	@nonobjc static let searchBackgroundRed = UIColor.colorFromCode(0x8A393D)
	@nonobjc static let searchTextColor = UIColor.white.withAlphaComponent(0.63)
	@nonobjc static let followLightRed = UIColor.colorFromCode(0xEBCECC)
	@nonobjc static let redTintedWhite = UIColor.colorFromCode(0xE3DCDC)
	@nonobjc static let sectionTitleGrey = UIColor.colorFromCode(0x636363)
	@nonobjc static let cellDarkGrey = UIColor.colorFromCode(0x212121)
	@nonobjc static let tempoOffBlack = UIColor.colorFromCode(0x101112)
	@nonobjc static let tempoMidGrey = UIColor.colorFromCode(0x787474)
	@nonobjc static let placeholderGrey = UIColor.colorFromCode(0x3F3F43)
	@nonobjc static let placeholderTextGrey = UIColor.colorFromCode(0xA8A3A3)
	@nonobjc static let profileButtonGrey = UIColor.colorFromCode(0xB5B1B1)
	@nonobjc static let profileBackgroundBlack = UIColor.colorFromCode(0x101112)
<<<<<<< a99dec6ff71380bddfd628c68bc26928d124552f
	@nonobjc static let postHistoryGrey = UIColor.colorFromCode(0x232427)
=======
>>>>>>> Remove ProfileVC xib and style vc

	public static func colorFromCode(_ code: Int) -> UIColor {
		let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
		let green = CGFloat(((code & 0xFF00) >> 8)) / 255
		let blue = CGFloat((code & 0xFF)) / 255
		
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}
