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
	static let width: CGFloat     = UIScreen.main.bounds.width
}

// MARK: - Banner View -

class BannerView: UIView {
	
	var notificationLabel: UILabel!
	
	override init(frame: CGRect) {
		let f = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: AWBannerProperties.height)
		super.init(frame: f)
		
		notificationLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: f.size))
		notificationLabel.font = notificationLabel.font.withSize(13)
		notificationLabel.textAlignment = .center
		
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
	
	fileprivate static let notificationView = BannerView()
	
	static func showBanner(_ topView: UIViewController, delay: TimeInterval, message: String, backgroundColor: UIColor, textColor: UIColor, originY y: CGFloat = originY) {
		
		guard let window = UIApplication.shared.delegate?.window, window != nil else {
			return
		}
		
		originY = y
		
		notificationView.notificationLabel.text      = message
		notificationView.backgroundColor             = backgroundColor
		notificationView.notificationLabel.textColor = textColor
		
		UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			
			topView.view.addSubview(self.notificationView)
			self.notificationView.frame = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: AWBannerProperties.height) }, completion: nil)
	}
	
	static func hide() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.notificationView.notificationLabel.text = " "
			self.notificationView.frame = CGRect(x: 0, y: originY, width: AWBannerProperties.width, height: 0)
			}, completion: { _ in
				self.notificationView.removeFromSuperview()
			})
		}
	
	static func APINotConnected(_ currentVC: UIViewController) {
		Banner.showBanner(
			currentVC,
			delay: 0,
			message: NSLocalizedString("Tempo must be down, sorry :(", comment: "Banner title that informs the user the notification API is down"),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.white,
			originY: 0)
	}
	
	static func internetNotConnected(_ currentVC: UIViewController) {
		print("Not connected internet")
		Banner.showBanner(
			currentVC,
			delay: 0,
			message: NSLocalizedString("No internet connection", comment: "Banner title that informs the user the notification internet is down"),
			backgroundColor: UIColor.tempoDarkGray,
			textColor: UIColor.white,
			originY: 0)
	}
}
