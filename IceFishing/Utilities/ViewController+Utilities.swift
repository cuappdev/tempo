//
//  ViewController+Bar.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import Foundation

extension UIViewController {
	func addHamburgerMenu() {
		let image = UIImage(named: "Hamburger-Menu")!
		let menuButton = UIButton(frame: CGRect(origin: CGPointZero, size: image.size))
		menuButton.setImage(image, forState: .Normal)
		menuButton.addTarget(revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
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
}
