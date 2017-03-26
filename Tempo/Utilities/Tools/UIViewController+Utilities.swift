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
