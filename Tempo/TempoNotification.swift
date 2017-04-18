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

protocol NotificationDelegate {
	func didTapNotification(forNotification notif: TempoNotification, cell: NotificationTableViewCell?, postHistoryVC: PostHistoryTableViewController?)
}

class TempoNotification: NSObject {
	let id: String?
	let user: User?
	let postId: String?
	let message: String
	let type: NotificationType
	let date: Date?
	var seen: Bool?

	init(id: String?, user: User?, postId: String?, message: String, type: NotificationType, date: Date?, seen: Bool?) {
		self.id = id
		self.user = user
		self.postId = postId
		self.message = message
		self.type = type
		self.date = date
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
		let type: NotificationType = json["data"]["type"].intValue == 1 ? .Like : .Follower
		let dateString = json["created_at"].stringValue
		let date = DateFormatter.parsingDateFormatter.date(from: dateString)
		
		self.init(id: id, user: user, postId: postId, message: message, type: type, date: date, seen: seen)
	}
	
	// Initialization for internet connectivity
	convenience init(msg: String, type: NotificationType = .InternetConnectivity) {
		self.init(id: nil, user: nil, postId: nil, message: msg, type: type, date: nil, seen: nil)
	}
	
	override var description: String {
		return message
	}
	
	var notificationDescription: String {
		return "\(user!.name): \(message) for the post \(postId!)"
	}
	
	func relativeDate() -> String {
		
		guard let date = date else { return "" }
		let now = Date()
		let seconds = max(0, Int(now.timeIntervalSince(date)))
		
		if seconds < 60 {
			return "\(seconds)s"
		}
		let minutes = seconds / 60
		if minutes == 1 {
			return "\(minutes)m"
		}
		if minutes < 60 {
			return "\(minutes)m"
		}
		let hours: Int = minutes / 60
		if hours == 1 {
			return "\(hours)h"
		}
		if hours < 24 {
			return "\(hours)h"
		}
		let days: Int = hours / 24
		if days == 1 {
			return "\(days)d"
		}
		return "\(days)d"
//		return "2017-04-16T20:25:44.153Z"
	}
	
}
