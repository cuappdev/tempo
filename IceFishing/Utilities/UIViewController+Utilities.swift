//
//  UIViewController+Utilities.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import Foundation
import SWRevealViewController

extension UIViewController {
	func addHamburgerMenu() {
		let image = UIImage(named: "Hamburger-Menu")!
		let menuButton = UIButton(frame: CGRect(origin: CGPointZero, size: image.size))
		menuButton.setImage(image, forState: .Normal)
		menuButton.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), forControlEvents: .TouchUpInside)
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
	}
	
	func addRevealGesture() {
		if revealViewController() != nil {
			view.addGestureRecognizer(revealViewController().panGestureRecognizer())
		}
	}
	
	func removeRevealGesture() {
		if revealViewController() != nil {
			view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
		}
	}
	
	func notConnected() {
		if !API.sharedAPI.isConnected {
			Banner.notConnected(self)
		} else if !API.sharedAPI.isAPIConnected {
			Banner.APINotConnected(self)
		}
	}
}