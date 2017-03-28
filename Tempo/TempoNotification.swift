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
	let userId: String?
	let postId: String?
	let message: String
	let type: NotificationType
	let seen: Bool?

	init(id: String?, userId: String?, postId: String?, message: String, type: NotificationType, seen: Bool?) {
		self.id = id
		self.userId = userId
		self.postId = postId
		self.message = message
		self.type = type
		self.seen = seen
		
		super.init()
	}
	
	// Initialization for tempo activity notification
	convenience init(json: JSON) {
		let id = json["id"].stringValue
		let userId = json["from"].stringValue
		let postId = json["post_id"].stringValue
		let message = json["message"].stringValue
		let type: NotificationType
		switch json["notification_type"].intValue {
		case 1:
			type = .Like
		case 2:
			type = .Follower
		default:
			type = .Like
		}
		let seen = (json["seen"].intValue) == 0 ? false : true
		
		self.init(id: id, userId: userId, postId: postId, message: message, type: type, seen: seen)
	}
	
	// Initialization for internet connectivity
	convenience init(msg: String, type: NotificationType = .InternetConnectivity) {
		self.init(id: nil, userId: nil, postId: nil, message: msg, type: type, seen: nil)
	}
	
	override var description: String {
		return message
	}
	
	var notificationDescription: String {
		return "\(userId): \(message) for the post \(postId)"
	}
	
}
