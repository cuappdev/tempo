//
//  PopAnimator.swift
//  IceFishing
//
//  Created by Monica Ong on 2/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	
	let duration    = 3.0
	var presenting  = true
	var originFrame = CGRect.zero
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
		return duration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView()!
		
		let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
		print(toView)
		let noteView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
		
		// calculate the scale factor you need to apply on each axis as you animate between each view
		let initialFrame = presenting ? originFrame : noteView.frame
		let finalFrame = presenting ? noteView.frame : originFrame
		print(initialFrame)
		print(finalFrame)
		let xScaleFactor = CGFloat(1.0)
//		let xScaleFactor = presenting ?	initialFrame.width / finalFrame.width :
//			finalFrame.width / initialFrame.width
		
		let yScaleFactor = CGFloat(1.0)
//		let yScaleFactor = presenting ?	initialFrame.height / finalFrame.height :
//			finalFrame.height / initialFrame.height
		
		//When presenting the new view, you set its scale and position so it exactly matches the size and location of the initial frame
		let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
		
		if presenting {
			noteView.transform = scaleTransform
			noteView.center = CGPoint(
				x: CGRectGetMidX(initialFrame),
				y: CGRectGetMidY(initialFrame))
			noteView.clipsToBounds = true
		}
		
		//Overlay background tint
		let mainScreenFrame = UIScreen.mainScreen().bounds
		let backgroundTint = UIView(frame: mainScreenFrame)
		backgroundTint.alpha = presenting ? 0 : 1
		
		containerView.addSubview(toView)
		containerView.addSubview(backgroundTint)
		containerView.bringSubviewToFront(noteView)
		
		UIView.animateWithDuration(duration, animations: {
			backgroundTint.alpha = self.presenting ? 1 : 0
			noteView.transform = self.presenting ?
				CGAffineTransformIdentity : scaleTransform
			noteView.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2,
				y: UIScreen.mainScreen().bounds.height/2)
			}, completion: {_ in
				transitionContext.completeTransition(true)
		})
	}
}

