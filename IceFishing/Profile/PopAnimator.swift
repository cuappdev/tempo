//
//  PopAnimator.swift
//  IceFishing
//
//  Created by Monica Ong on 2/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	
	let duration    = 0.5
	var presenting  = true
	var originFrame = CGRect.zero
	var profileImage = UIImage()
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
		return duration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let profilePicViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ProfilePictureViewController
		
		profilePicViewController.view.frame = transitionContext.containerView()!.frame
		profilePicViewController.view.alpha = 0
		
		transitionContext.containerView()?.addSubview(profilePicViewController.view)
		
		profilePicViewController.profilePictureView.image = profileImage
		
		UIView.animateWithDuration(duration) { () -> Void in
			profilePicViewController.view.alpha = 1
		}
	}
}

