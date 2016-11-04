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
		
		let hamburgerIconView = HamburgerIconView(frame: CGRectMake(0, 0, 30, 30), color: UIColor.whiteColor().colorWithAlphaComponent(0.85), lineWidth: 2, iconWidthRatio: 0.50)
		hamburgerIconView.addTarget(self, action: #selector(UIViewController.toggleHamburger(_:)), forControlEvents: .TouchUpInside)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerIconView)
	}
	
	func toggleHamburger(hamburgerIconView: HamburgerIconView) {
		revealViewController().revealToggle(hamburgerIconView)
	}
	
	// If not connected to internet return true and display banner if animated
	func notConnected(animated: Bool) -> Bool {
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
		view.window!.layer.addAnimation(transition, forKey: nil)
		dismissViewControllerAnimated(false, completion: nil)
	}
}