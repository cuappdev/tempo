//
//  NotificationBannerProtocol.swift
//  Tempo
//
//  Created by Natasha Armbrust on 11/22/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//
//code adopted from github.com/Aymenworks/AWBanner
import UIKit

// MARK: - Banner Properties -
private struct BannerProperties {
	static let height: CGFloat = 50
	static let width: CGFloat  = UIScreen.main.bounds.width
}

private let originY: CGFloat = -BannerProperties.height

protocol NotificationDelegate {
	func didTapNotification(forNotification notif: TempoNotification, cell: NotificationTableViewCell?, postHistoryVC: PostHistoryTableViewController?)
}

// MARK: - Banner View -
class BannerView: UIView {
	
	var notificationLabel: UILabel!
	var notification: TempoNotification!
	var delegate: NotificationDelegate?
	
	override init(frame: CGRect) {
		let f = CGRect(x: 0, y: originY, width: BannerProperties.width, height: BannerProperties.height)
		super.init(frame: f)
		
		notificationLabel = UILabel(frame: CGRect(x: 16, y: originY, width: BannerProperties.width - 32, height: BannerProperties.height))
		notificationLabel.backgroundColor = .clear
		notificationLabel.font = UIFont(name: "AvenirNext-Medium", size: 13)
		notificationLabel.textAlignment = .left
		notificationLabel.text = "Placeholder Text"
		self.addSubview(notificationLabel)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTap))
		self.addGestureRecognizer(tapGesture)
		
		let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSwipe))
		self.addGestureRecognizer(swipeGesture)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func hideTap() {
		Banner.hide()
		if notification.type != .InternetConnectivity {
			delegate?.didTapNotification(forNotification: notification, cell: nil, postHistoryVC: nil)
		}
	}
	
	func hideSwipe(sender: UISwipeGestureRecognizer) {
		if sender.direction == .up { Banner.hide() }
	}
}

class Banner {
	
	fileprivate static let notificationView = BannerView()
	
	static func showBanner(_ topView: UIViewController, delay: TimeInterval, data: TempoNotification, backgroundColor: UIColor, textColor: UIColor, delegate: NotificationDelegate? = nil) {
		
		guard let window = UIApplication.shared.delegate?.window, window != nil else {
			return
		}
		
		notificationView.delegate					 = delegate
		notificationView.notification				 = data
		notificationView.notificationLabel.text      = data.message
		notificationView.backgroundColor             = backgroundColor
		notificationView.notificationLabel.textColor = textColor
		
		UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			topView.view.addSubview(self.notificationView)
			self.notificationView.frame = CGRect(x: 0, y: 0, width: BannerProperties.width, height: BannerProperties.height)
			self.notificationView.notificationLabel.frame = CGRect(x: 10, y: 0, width: BannerProperties.width - 20, height: BannerProperties.height)
		}, completion: nil)
		
		// Hide banner after 4.0 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { self.hide() }
	}
	
	static func hide() {
		UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.notificationView.notificationLabel.text = " "
			self.notificationView.frame = CGRect(x: 0, y: originY, width: BannerProperties.width, height: 0)
		}, completion: { _ in
			self.notificationView.removeFromSuperview()
		})
	}
	
	static func APINotConnected(_ currentVC: UIViewController) {
		Banner.showBanner(
			currentVC,
			delay: 0,
			data: TempoNotification(msg: "Tempo must be down, sorry :("),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.white)
	}
	
	static func internetNotConnected(_ currentVC: UIViewController) {
		Banner.showBanner(
			currentVC,
			delay: 0,
			data: TempoNotification(msg: "No internet connection"),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.white)
	}
}
