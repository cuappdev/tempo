//
//  TempoNotification.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

enum NotificationType {
	case Like
	case Follower
	case InternetConnectivity
}

class TempoNotification: NSObject {
	let id: String?
	let user: User?
	let postId: String?
	let message: String
	let type: NotificationType
	let seen: Bool?

	init(id: String?, user: User?, postId: String?, message: String, type: NotificationType, seen: Bool?) {
		self.id = id
		self.user = user
		self.postId = postId
		self.message = message
		self.type = type
		self.seen = seen
		
		super.init()
	}
	
	// Initialization for tempo activity notification
	convenience init(json: JSON) {
		let id = json["id"].stringValue
		let message = json["message"].stringValue
		let seen = (json["seen"].intValue) == 0 ? false : true
		let user = User(json: json["data"]["from"])
		let postId = json["data"]["post_id"].stringValue
		print(json)
		let type: NotificationType = json["data"]["type"].intValue == 1 ? .Like : .Follower
		
		self.init(id: id, user: user, postId: postId, message: message, type: type, seen: seen)
	}
	
	// Initialization for internet connectivity
	convenience init(msg: String, type: NotificationType = .InternetConnectivity) {
		self.init(id: nil, user: nil, postId: nil, message: msg, type: type, seen: nil)
	}
	
	override var description: String {
		return message
	}
	
	var notificationDescription: String {
		return "\(user): \(message) for the post \(postId)"
	}
	
}
