//
//  Util.swift
//  IceFishing
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

extension UIView {
	func fadeIn(duration: NSTimeInterval = 1, delay: NSTimeInterval = 0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
		UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.alpha = 1
			}, completion: completion)
	}
	
	func fadeOut(duration: NSTimeInterval = 1, delay: NSTimeInterval = 0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
		UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.alpha = 0
			}, completion: completion)
	}
}

func getTopViewController() -> UIViewController {
	var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
	
	while topVC?.presentedViewController != nil {
		topVC = topVC?.presentedViewController
	}
	
	return topVC!
}

func delay(delay: Double, closure:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

func transparentPNG(length: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(length, length), false, 0)
    let blank = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return blank
}
