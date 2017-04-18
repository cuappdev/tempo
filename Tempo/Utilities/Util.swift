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

let tabBarHeight = CGFloat(50.0)
let miniPlayerHeight = CGFloat(72.0)
let expandedPlayerHeight = CGFloat(347.0)
let iPhone5: Bool = (UIScreen.main.bounds.width <= CGFloat(320))

enum ContentType: String {
	case Following = "Following"
	case Followers = "Followers"
	case Users = "Users"
	case Liked = "Liked"
	case Feed = "Feed"
}

extension UIViewController {
	// If not connected to internet return true and display banner if animated
	func notConnected(_ animated: Bool) -> Bool {
		if !API.sharedAPI.isConnected {
			if animated { Banner.internetNotConnected(self) }
			return true
		} else if !API.sharedAPI.isAPIConnected {
			if animated { Banner.APINotConnected(self) }
			return true
		}
		return false
	}
	
	func dismissVCWithFadeAnimation() {
		let transition = CATransition()
		transition.duration = 0.3
		transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		transition.type = kCATransitionFade
		view.window!.layer.add(transition, forKey: nil)
		dismiss(animated: false, completion: nil)
	}
}

extension UIView {
	class func viewForEmptyViewController(_ type: ContentType, size: CGSize, isCurrentUser: Bool, userFirstName: String) -> UIView {
		let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		
		var image: UIImage?
		var labelText: String
		
		switch type {
		case .Feed:
			labelText = "No posts in the last 24 hours."
		case .Followers:
			image = #imageLiteral(resourceName: "FollowersEmptyStateIcon")
			labelText = isCurrentUser ? "You have no followers right now.\nTell your friends to follow you!" : "\(userFirstName) doesn't have any followers.\nFollow them!"
		case .Following:
			image = #imageLiteral(resourceName: "FollowingEmptyStateIcon")
			labelText = isCurrentUser ? "Follow your Facebook friends to\nview them here!" : "\(userFirstName) is not following anyone."
		case .Users:
			image = #imageLiteral(resourceName: "UsersEmptyStateIcon")
			labelText = "Search for your friends!"
		case .Liked:
			image = #imageLiteral(resourceName: "LikedEmptyStateIcon")
			labelText = "Like songs on your home feed\nto view them here!"
		}
		
		let imageView = UIImageView(image: image)
		imageView.frame.origin = CGPoint(x: size.width/2 - imageView.bounds.width/2, y: size.height/2 - imageView.bounds.height/2)
		
		let label = UILabel(frame: CGRect(x: 0, y: imageView.bounds.height/2 + 30, width: size.width, height: size.height))
		label.text = labelText
		label.textColor = .white
		label.font = UIFont(name: "AvenirNext-Regular", size: 16)
		label.numberOfLines = 2
		label.textAlignment = .center
		
		emptyView.addSubview(imageView)
		emptyView.addSubview(label)
		
		return emptyView
	}
	
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


