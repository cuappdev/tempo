//
//  BackendNotConnectedProtocol.swift
//  Tempo
//
//  Created by Natasha Armbrust on 11/22/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

//code adopted from github.com/Aymenworks/AWBanner

import UIKit

// MARK: - Banner Properties -

private var originY: CGFloat = 0

private struct AWBannerProperties {
	static let height: CGFloat    = 50
	static let width: CGFloat     = UIScreen.mainScreen().bounds.width
}

// MARK: - Banner View -

class BannerView: UIView {
	
	var notificationLabel: UILabel!
	
	override init(frame: CGRect) {
		let f = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: AWBannerProperties.height)
		super.init(frame: f)
		
		notificationLabel = UILabel(frame: CGRect(origin: CGPointZero, size: f.size))
		notificationLabel.font = notificationLabel.font.fontWithSize(13)
		notificationLabel.textAlignment = .Center
		
		self.addSubview(notificationLabel)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
		self.addGestureRecognizer(tapGesture)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func hide() {
		Banner.hide()
	}
}

class Banner {
	
	private static let notificationView = BannerView()
	
	static func showWithDuration(topView: UIViewController, duration: NSTimeInterval, delay: NSTimeInterval, message: String, backgroundColor: UIColor, textColor: UIColor, originY y: CGFloat = originY) {
		
		guard let window = UIApplication.sharedApplication().delegate?.window where window != nil else {
			return
		}
		
		originY = y
		
		notificationView.notificationLabel.text      = message
		notificationView.backgroundColor             = backgroundColor
		notificationView.notificationLabel.textColor = textColor
		
		UIView.animateWithDuration(0.5, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveLinear, animations: {
			
			topView.view.addSubview(self.notificationView)
			self.notificationView.frame = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: AWBannerProperties.height) }, completion: nil)
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
			self.hide()
		}
	}
	
	static func hide() {
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveLinear, animations: {
			self.notificationView.notificationLabel.text = " "
			self.notificationView.frame = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: 0)
			}, completion: { _ in
				self.notificationView.removeFromSuperview()
			})
		}
	
	static func APINotConnected(currentVC: UIViewController) {
		Banner.showWithDuration(
			currentVC,
			duration: 4,
			delay: 0,
			message: NSLocalizedString("Tempo must be down, sorry :(", comment: "Banner title that informs the user the notification API is down"),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.whiteColor(),
			originY: 0)
	}
	
	static func notConnected(currentVC: UIViewController) {
		print("Not connected internet")
		Banner.showWithDuration(
			currentVC,
			duration: 4,
			delay: 0,
			message: NSLocalizedString("No internet connection", comment: "Banner title that informs the user the notification internet is down"),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.whiteColor(),
			originY: 0)
	}
}