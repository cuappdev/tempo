//
//  UIView+Utilities.swift
//  IceFishing
//
//  Created by Mark Bryan on 3/2/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation

enum ContentType: String {
	case Following = "Following"
	case Followers = "Followers"
	case Users = "Users"
	case Liked = "Liked"
	case Feed = "Feed"
}

extension UIView {
	
	class func viewForEmptyViewController(type: ContentType, size: CGSize, isCurrentUser: Bool, userFirstName: String) -> UIView {
		let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		
		var image: UIImage?
		var labelText: String
		
		switch type {
		case .Feed:
			labelText = "No posts in the last 24 hours"
		case .Followers:
			image = UIImage(named: "followers")!
			labelText = isCurrentUser ? "No followers right now\nTell your friends to follow you!" : "\(userFirstName) doesn't have any followers\nFollow them!"
		case .Following:
			image = UIImage(named: "following")!
			labelText = isCurrentUser ? "Follow your Facebook friends to\nview them here!" : "\(userFirstName) is not following anyone"
		case .Users:
			image = UIImage(named: "search-glass")!
			labelText = "Search for your friends!"
		case .Liked:
			image = UIImage(named: "liked-thumb")!
			labelText = "Like songs on your home feed\nto view them here!"
		}
		
		let imageView = UIImageView(image: image)
		imageView.frame.origin = CGPoint(x: size.width/2 - imageView.bounds.width/2, y: size.height/2 - imageView.bounds.height/2)
		
		let label = UILabel(frame: CGRect(x: 0, y: imageView.bounds.height/2 + 30, width: size.width, height: size.height))
		label.text = labelText
		label.textColor = UIColor.whiteColor()
		label.font = UIFont(name: "AvenirNext-Regular", size: 16)
		label.numberOfLines = 2
		label.textAlignment = .Center
		
		emptyView.addSubview(imageView)
		emptyView.addSubview(label)
		
		return emptyView
	}
	
}