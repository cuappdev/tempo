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
	var usernameLabel = UILabel()
	var messageLabel = UILabel()
	var descriptionLabel = UILabel()
	var timeLabel = UILabel()
	var unreadIndicator = UIView()
//	var acceptButton = UIButton()
	var customSeparator = UIView()
	var seen = false
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let width = UIScreen.main.bounds.width
		
		avatarImage.frame = CGRect(x: 16, y: 10, width: notificationCellHeight - 20, height: notificationCellHeight - 20)
		avatarImage.layer.cornerRadius = avatarImage.bounds.size.width / 2
		avatarImage.clipsToBounds = true
		contentView.addSubview(avatarImage)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImage(_:)))
		avatarImage.isUserInteractionEnabled = true
		avatarImage.addGestureRecognizer(tapGestureRecognizer)
		
		let x = avatarImage.frame.maxX + 16
		usernameLabel.frame = CGRect(x: x, y: 8, width: 50, height: notificationCellHeight/2 - 8)
		usernameLabel.backgroundColor = .clear
		usernameLabel.textColor = .white
		usernameLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
		contentView.addSubview(usernameLabel)
		
		messageLabel.frame = CGRect(x: x, y: 8, width: width - (x+50), height: notificationCellHeight/2 - 8)
		messageLabel.backgroundColor = .clear
		messageLabel.textColor = .cellOffWhite
		messageLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
		contentView.addSubview(messageLabel)
		
		descriptionLabel.frame = CGRect(x: x, y: notificationCellHeight/2, width: width - (x+50), height: notificationCellHeight/2 - 8)
		descriptionLabel.backgroundColor = .clear
		descriptionLabel.textColor = .cellOffWhite
		descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
		contentView.addSubview(descriptionLabel)
		
//		acceptButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 15, width: 80, height: notificationCellHeight - 30)
//		acceptButton.backgroundColor = UIColor.tempoRed
//		acceptButton.layer.cornerRadius = 4
//		acceptButton.setAttributedTitle(NSAttributedString(string: "Accept", attributes: [NSForegroundColorAttributeName: UIColor.white]), for: .normal)
//		acceptButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
//		acceptButton.isHidden = true
//		contentView.addSubview(acceptButton)
		
		timeLabel.frame = CGRect(x: width - 46, y: 10, width: 34, height: notificationCellHeight - 20)
		timeLabel.backgroundColor = .clear
		timeLabel.textColor = .cellOffWhite
		timeLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
		timeLabel.textAlignment = .right
		contentView.addSubview(timeLabel)
		
		unreadIndicator.frame = CGRect(x: width - 10, y: notificationCellHeight/2 - 4, width: 8, height: 8)
		unreadIndicator.layer.cornerRadius = 4
		unreadIndicator.backgroundColor = .clear
		contentView.addSubview(unreadIndicator)
		
		customSeparator.frame = CGRect(x: 0, y: notificationCellHeight-1, width: UIScreen.main.bounds.width, height: 1)
		customSeparator.backgroundColor = .readCellColor
		contentView.addSubview(customSeparator)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupCell(notification: TempoNotification) {
		contentView.backgroundColor = .unreadCellColor
		selectionStyle = .none
		
		self.notification = notification
		self.user = notification.user
		self.seen = notification.seen!
		
		avatarImage.hnk_setImageFromURL(user.imageURL)
		
		// Adjust label widths to match text content
		usernameLabel.text = "@\(user.username)"
		let oldFrame = usernameLabel.frame
		usernameLabel.sizeToFit()
		let newFrame = usernameLabel.frame
		usernameLabel.frame = CGRect(origin: oldFrame.origin, size: CGSize(width: newFrame.width, height: oldFrame.height))
		
		messageLabel.frame = CGRect(x: usernameLabel.frame.maxX, y: 8, width: timeLabel.frame.minX - (usernameLabel.frame.maxX+10), height: usernameLabel.frame.height)
		
		if notification.type == .Like {
			let songName = notification.message.components(separatedBy: ": ").last?.components(separatedBy: "!").first
			messageLabel.text =  " liked your song"
			descriptionLabel.text = songName
			timeLabel.isHidden = false
		} else {
			messageLabel.text = ""
			descriptionLabel.text = user.name
		}
		timeLabel.text = notification.relativeDate()
		
		updateCell()
		markAsSeen()
	}

	func markAsSeen() {
		if !seen {
			API.sharedAPI.checkNotification(notification.id!, completion: { (success) in
				if success {
					TabBarController.sharedInstance.unreadNotificationCount -= 1
					self.notification.seen = true
					self.seen = true
					Thread.sleep(forTimeInterval: 0.6)
					self.updateCell()
				}
			})
		}
	}
	
	func updateCell() {
		unreadIndicator.backgroundColor = seen ? .clear : .tempoRed
	}
	
	func didTapAvatarImage(_ : UITapGestureRecognizer) {
		delegate?.didTapUserImageForNotification(user)
	}

}
