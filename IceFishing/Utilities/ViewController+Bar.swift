//
//  ViewController+Bar.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import Foundation

extension UIViewController {
    func beginIceFishing() {        
        //—————————————from MAIN VC——————————————————
        navigationItem.title = self.title
        
        // Add hamburger menu to the left side of the navbar
		let image = UIImage(named: "Hamburger-Menu")!
        let menuButton = UIButton(frame: CGRect(origin: CGPointZero, size: image.size))
        menuButton.setImage(image, forState: .Normal)
        menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        // Pop out sidebar when hamburger menu tapped
        if revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			revealViewController().panGestureRecognizer()
			revealViewController().tapGestureRecognizer()
        }
    }
}

extension UIView {
	class func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: () -> Void) {
		animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: nil)
	}
}
