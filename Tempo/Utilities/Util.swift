//
//  Util.swift
//  Tempo
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

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
