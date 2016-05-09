//
//  ADRefreshControl.swift
//  JackrabbitRefreshSwift
//
//  Created by Dennis Fedorko on 5/4/15.
//  Copyright (c) 2015 Jackrabbit Mobile. All rights reserved.
//

import UIKit

class ADRefreshControl {
	
	var refreshControl: UIRefreshControl!
	var vinylView: UIImageView!
	var vinylCaseFront: UIImageView!
	var vinylCaseBack: UIView!
	var isRefreshAnimating = false
	var timesAnimationLooped = 0
	var pullDistance: CGFloat = 0
	
	init(refreshControl: UIRefreshControl) {
		
		self.refreshControl = refreshControl
		
		// Create the graphic image views
		vinylView = UIImageView(image: UIImage(named: "Vinyl-Red"))
		vinylView.frame = CGRectMake(0, 0, 40, 40)
		
		vinylCaseBack = UIView(frame: CGRectMake(0, 0, 50, 50))
		vinylCaseBack.backgroundColor = UIColor(red: 181/255.0, green: 72/255.0, blue: 65/255.0, alpha: 1.0)
		
		vinylCaseFront = UIImageView(image: UIImage(named: "vinylCase"))
		vinylCaseFront.frame = CGRectMake(0, 0, 50, 50)
		
		// Add the graphics to the loading view
		refreshControl.addSubview(vinylCaseBack)
		refreshControl.addSubview(vinylView)
		refreshControl.addSubview(vinylCaseFront)
		
		// Hide the original spinner icon
		refreshControl.tintColor = UIColor.clearColor()
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		// Get the current size of the refresh controller
		var refreshBounds = refreshControl.bounds
		
		// Distance the table has been pulled >= 0
		let newPullDistance = max(0, -refreshControl.frame.origin.y)
		
		if !isRefreshAnimating {
			let direction = newPullDistance < pullDistance ? -10.0 : 10.0
			vinylView.transform = CGAffineTransformRotate(vinylView.transform, CGFloat(direction * M_PI/180))
		}
		
		pullDistance = newPullDistance
		
		if (pullDistance == 0) {
			vinylCaseFront.alpha = 1.0
			vinylCaseBack.alpha = 1.0
		} else if pullDistance > 110 {
			vinylCaseFront.alpha = 0.0
			vinylCaseBack.alpha = 0.0
		}
		
		//have vinyl case follow disc up to a certain point then return
		vinylView.center = CGPointMake(refreshBounds.size.width/2.0, pullDistance / 2.0)
		let followDistance: CGFloat = 30.0
		if pullDistance / 2.0 < followDistance {
			vinylCaseFront.center = CGPointMake(refreshBounds.size.width / 2.0, pullDistance / 2.0)
			vinylCaseBack.center = CGPointMake(refreshBounds.size.width / 2.0, pullDistance / 2.0)
		} else {
			vinylCaseFront.center = CGPointMake(refreshBounds.size.width / 2.0, followDistance - 2.0 * (pullDistance / 2.0 - followDistance))
			vinylCaseBack.center = CGPointMake(refreshBounds.size.width / 2.0, followDistance - 2.0 * (pullDistance / 2.0 - followDistance))
		}
		
		// Set the encompassing view's frames
		refreshBounds.size.height = pullDistance
		
		// If we're refreshing and the animation is not playing, then play the animation
		if refreshControl!.refreshing && !isRefreshAnimating {
			animateRefreshView()
		}
	}
	
	func animateRefreshView() {
		
		// Flag that we are animating
		isRefreshAnimating = true
		
		//make sure vinyl case is hidden
		vinylCaseFront.alpha = 0.0
		vinylCaseBack.alpha = 0.0
		
		UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {

			// Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
			self.vinylView.transform = CGAffineTransformRotate(self.vinylView.transform, CGFloat(-1 * M_PI_2))
			if self.timesAnimationLooped % 2 == 0 {
				self.vinylView.transform = CGAffineTransformScale(self.vinylView.transform, 1.30, 1.30)
			} else {
				self.vinylView.transform = CGAffineTransformScale(self.vinylView.transform, 1/1.3, 1/1.3)
			}
		}, completion: { finished in
			// If still refreshing, keep spinning, else reset
			if self.refreshControl.refreshing {
				self.animateRefreshView()
			} else {
				self.resetAnimation()
			}
		})
		timesAnimationLooped += 1
	}
	
	func resetAnimation() {
		
		// Reset our flags and background color
		if timesAnimationLooped % 2 != 0 {
			vinylView.transform = CGAffineTransformScale(vinylView.transform, 1/1.3, 1/1.3)
		}
		timesAnimationLooped = 0
		isRefreshAnimating = false
		
		
	}
	
}
