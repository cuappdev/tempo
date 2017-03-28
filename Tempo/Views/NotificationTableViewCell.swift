//
//  NotificationTableViewCell.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate {
	func didTapUserImageForNotification(_ user: User)
}

class NotificationTableViewCell: UITableViewCell {
	
	var notification: TempoNotification!
	var user: User!
	var delegate: NotificationCellDelegate?
	
	var avatarImage = UIImageView()
	var messageLabel = UILabel()
	var descriptionLabel = UILabel()
	var timeLabel = UILabel()
	var acceptButton = UIButton()
	var customSeparator = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		avatarImage.frame = CGRect(x: 10, y: 10, width: notificationCellHeight - 20, height: notificationCellHeight - 20)
		avatarImage.layer.cornerRadius = avatarImage.bounds.size.width / 2
		avatarImage.clipsToBounds = true
		contentView.addSubview(avatarImage)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImage(_:)))
		avatarImage.isUserInteractionEnabled = true
		avatarImage.addGestureRecognizer(tapGestureRecognizer)
		
		let x = avatarImage.frame.maxX + 10
		messageLabel.frame = CGRect(x: x, y: 8, width: UIScreen.main.bounds.width - (x+10), height: notificationCellHeight/2 - 8)
		messageLabel.backgroundColor = .clear
		messageLabel.textColor = .white
		messageLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
		contentView.addSubview(messageLabel)
		
		descriptionLabel.frame = CGRect(x: x, y: notificationCellHeight/2, width: UIScreen.main.bounds.width - (x+50), height: notificationCellHeight/2 - 8)
		descriptionLabel.backgroundColor = .clear
		descriptionLabel.textColor = .cellOffWhite
		descriptionLabel.font = UIFont(name: "AvenirNext-Medium", size: 13)
		contentView.addSubview(descriptionLabel)
		
		timeLabel.frame = CGRect(x: UIScreen.main.bounds.width - 40, y: 10, width: 30, height: notificationCellHeight - 20)
		timeLabel.backgroundColor = .clear
		timeLabel.textColor = .cellOffWhite
		timeLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
		contentView.addSubview(timeLabel)
		
		acceptButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 15, width: 80, height: notificationCellHeight - 30)
		acceptButton.backgroundColor = UIColor.tempoRed
		acceptButton.layer.cornerRadius = 4
		acceptButton.setAttributedTitle(NSAttributedString(string: "Accept", attributes: [NSForegroundColorAttributeName: UIColor.white]), for: .normal)
		acceptButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
		acceptButton.isHidden = true
		contentView.addSubview(acceptButton)
		
		customSeparator.frame = CGRect(x: 0, y: notificationCellHeight-1, width: UIScreen.main.bounds.width, height: 1)
		customSeparator.backgroundColor = .readCellColor
		contentView.addSubview(customSeparator)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupCell(notification: TempoNotification, user: User) {
		contentView.backgroundColor = .unreadCellColor
		selectionStyle = .none
		
		self.notification = notification
		self.user = user
		
		avatarImage.hnk_setImageFromURL(user.imageURL)
		
		if notification.type == .Like {
			messageLabel.text = "@\(user.username) liked your song"
			descriptionLabel.text = "Blah blah"
			timeLabel.text = "1h"
			timeLabel.isHidden = false
			acceptButton.isHidden = true
		} else {
			messageLabel.text = "@\(user.username)"
			descriptionLabel.text = user.name
			timeLabel.isHidden = true
			acceptButton.isHidden = false
		}
	}

	func markAsSeen() {
		if !notification.seen! {
			API.sharedAPI.checkNotification(notification.id!) {
				self.descriptionLabel.textColor = $0 ? .white : .yellow
			}
		}
	}
	
	func didTapAvatarImage(_ : UITapGestureRecognizer) {
		delegate?.didTapUserImageForNotification(user)
	}

}
