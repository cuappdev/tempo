//
//  Util.swift
//  Tempo
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

struct ScreenSize {
	static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
	static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
	static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
	static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
	static let IS_IPHONE_5_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH <= 568.0
	static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
	static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
	static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

extension UIView {
	func fadeIn(_ duration: TimeInterval = 1, delay: TimeInterval = 0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.alpha = 1
			}, completion: completion)
	}
	
	func fadeOut(_ duration: TimeInterval = 1, delay: TimeInterval = 0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
		UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.alpha = 0
			}, completion: completion)
	}
}

extension String {
	func chopPrefix(_ count: Int = 1) -> String {
		return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
	}
}

func getTopViewController() -> UIViewController {
	var topVC = UIApplication.shared.keyWindow?.rootViewController
	
	while topVC?.presentedViewController != nil {
		topVC = topVC?.presentedViewController
	}
	
	return topVC!
}

func delay(_ delay: Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func transparentPNG(_ length: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: length, height: length), false, 0)
    let blank = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return blank!
}

func setUserInitials(firstName: String, lastName: String) -> String {
	var initials: String = ""
	
	if !firstName.isEmpty {
		initials += "\(firstName.characters.first!)"
	}
	
	if !lastName.isEmpty {
		initials += "\(lastName.characters.first!)"
	}
	
	return initials
}


