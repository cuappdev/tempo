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
		//—————————————from MAIN VC——————————————————
		navigationItem.title = title
		
		// Add hamburger menu to the left side of the navbar
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
}
