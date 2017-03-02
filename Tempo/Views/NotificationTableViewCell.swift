//
//  NotificationTableViewCell.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
	
	var notificationLabel: UILabel = UILabel()
	var notification: TempoNotification!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
	}
	
	func setupCell(notification: TempoNotification) {
		contentView.backgroundColor = .clear
		selectionStyle = .none
		
		self.notification = notification
		notificationLabel.frame = CGRect(x: 10, y: 0, width: contentView.frame.width - 20, height: contentView.frame.height)
		notificationLabel.backgroundColor = .clear
		notificationLabel.textColor = notification.seen! ? .white : .gray
		notificationLabel.font = UIFont(name: "AvenirNext", size: 12)
		notificationLabel.text = notification.description
		
		contentView.addSubview(notificationLabel)
	}
	
	func updateCell(success: Bool) {
		notificationLabel.textColor = success ? .white : .gray
	}

}
