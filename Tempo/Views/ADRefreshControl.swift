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
	var isRefreshAnimating = false
	var timesAnimationLooped = 0
	var pullDistance: CGFloat = 0
	
	init(refreshControl: UIRefreshControl) {
		
		self.refreshControl = refreshControl
		
		// Create the graphic image views
		vinylView = UIImageView(image: UIImage(named: "vinyl-red")?.withRenderingMode(.alwaysTemplate))
		vinylView.tintColor = UIColor.tempoLightRed
		vinylView.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
		vinylView.layer.opacity = 0
		
		// Add the graphics to the loading view
		refreshControl.addSubview(vinylView)
		
		// Hide the original spinner icon
		refreshControl.tintColor = UIColor.clear
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		// Get the current size of the refresh controller
		var refreshBounds = refreshControl.bounds
		
		// Distance the table has been pulled >= 0
		let newPullDistance = max(0, -refreshControl.frame.origin.y)
		
		if !isRefreshAnimating {
			let direction = newPullDistance < pullDistance ? -10.0 : 10.0
			vinylView.transform = vinylView.transform.rotated(by: CGFloat(direction * M_PI/180))
		}
		
		pullDistance = newPullDistance
		
		// Animate vinyl opacity when initially appearing/fading
		vinylView.layer.opacity = isRefreshAnimating ? 1.0 : Float(pullDistance-10.0)/45.0
		
		//have vinyl case follow disc up to a certain point then return
		vinylView.center = CGPoint(x: refreshBounds.size.width/2.0, y: pullDistance/2.0)
		
		// Set the encompassing view's frames
		refreshBounds.size.height = pullDistance
		
		// If we're refreshing and the animation is not playing, then play the animation
		if refreshControl!.isRefreshing && !isRefreshAnimating {
			animateRefreshView()
		}
	}
	
	func animateRefreshView() {
		
		// Flag that we are animating
		isRefreshAnimating = true
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {

			// Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
			self.vinylView.transform = self.vinylView.transform.rotated(by: CGFloat(-1 * M_PI_2))
			if self.timesAnimationLooped % 2 == 0 {
				self.vinylView.transform = self.vinylView.transform.scaledBy(x: 1.30, y: 1.30)
			} else {
				self.vinylView.transform = self.vinylView.transform.scaledBy(x: 1/1.3, y: 1/1.3)
			}
		}, completion: { finished in
			// If still refreshing, keep spinning, else reset
			if self.refreshControl.isRefreshing {
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
			vinylView.transform = vinylView.transform.scaledBy(x: 1/1.3, y: 1/1.3)
		}
		timesAnimationLooped = 0
		isRefreshAnimating = false
	}
	
}
