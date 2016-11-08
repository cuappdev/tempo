//
//  UIViewController+Utilities.swift
//  Tempo
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import Foundation
import SWRevealViewController

extension UIViewController {
	
	func addHamburgerMenu() {
		
		let hamburgerIconView = HamburgerIconView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), color: UIColor.white.withAlphaComponent(0.85), lineWidth: 2, iconWidthRatio: 0.50)
		hamburgerIconView.addTarget(self, action: #selector(UIViewController.toggleHamburger(_:)), for: .touchUpInside)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerIconView)
	}
	
	func toggleHamburger(_ hamburgerIconView: HamburgerIconView) {
		revealViewController().revealToggle(hamburgerIconView)
	}
	
	// If not connected to internet return true and display banner if animated
	func notConnected(_ animated: Bool) -> Bool {
		if !API.sharedAPI.isConnected {
			if animated { Banner.internetNotConnected(self) }
			return true
		} else if !API.sharedAPI.isAPIConnected {
			if animated { Banner.APINotConnected(self) }
			return true
		}
		return false
	}
	
	func dismissVCWithFadeAnimation() {
		let transition = CATransition()
		transition.duration = 0.3
		transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		transition.type = kCATransitionFade
		view.window!.layer.add(transition, forKey: nil)
		dismiss(animated: false, completion: nil)
	}
}
