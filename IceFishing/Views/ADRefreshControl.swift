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
	var graphicView: UIImageView!
	var refreshColorView: UIView!
	var isRefreshAnimating = false
	var timesAnimationLooped = 0
	var pullDistance: CGFloat = 0
	var colorIndex = 0
	
	init(refreshControl: UIRefreshControl) {
		
		self.refreshControl = refreshControl
		
		// Setup the color view, which will display the rainbowed background
		refreshColorView = UIView(frame: refreshControl.bounds)
		refreshColorView.backgroundColor = UIColor.clearColor()
		refreshColorView.alpha = 0.30
		
		// Create the graphic image views
		graphicView = UIImageView(image: UIImage(named: "Vinyl-Red"))
		graphicView.frame = CGRectMake(0, 0, 45, 45)
		
		// Add the graphics to the loading view
		refreshControl.addSubview(graphicView)
		
		// Hide the original spinner icon
		refreshControl.tintColor = UIColor.clearColor()
		
		// Add the loading and colors views to our refresh control
		refreshControl.addSubview(self.refreshColorView)
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		// Get the current size of the refresh controller
		var refreshBounds = self.refreshControl.bounds
		
		// Distance the table has been pulled >= 0
		let newPullDistance = max(0.0, -self.refreshControl.frame.origin.y)
		
		if(!isRefreshAnimating) {
			let direction = newPullDistance < pullDistance ? -10.0 : 10.0
			graphicView.transform = CGAffineTransformRotate(graphicView.transform, CGFloat(direction * M_PI/180))
		}
		
		pullDistance = newPullDistance
		
		graphicView.center = CGPointMake(refreshBounds.size.width/2.0, pullDistance / 2.0)
		
		// Set the encompassing view's frames
		refreshBounds.size.height = pullDistance
		
		self.refreshColorView.frame = refreshBounds
		
		// If we're refreshing and the animation is not playing, then play the animation
		if self.refreshControl!.refreshing && !self.isRefreshAnimating {
			self.animateRefreshView()
		}
		
	}
	
	func animateRefreshView() {
		
		// Background color to loop through for our color view
		
		var colorArray = [UIColor.redColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.cyanColor(), UIColor.orangeColor(), UIColor.magentaColor()]
		
		// Flag that we are animating
		self.isRefreshAnimating = true
		
		UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
			// Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
			self.graphicView.transform = CGAffineTransformRotate(self.graphicView.transform, CGFloat(-1 * M_PI_2))
			if(self.timesAnimationLooped % 2 == 0) {
				self.graphicView.transform = CGAffineTransformScale(self.graphicView.transform, 1.30, 1.30)
			} else {
				self.graphicView.transform = CGAffineTransformScale(self.graphicView.transform, 1/1.3, 1/1.3)
			}
			// Change the background color
			self.refreshColorView.backgroundColor = colorArray[self.colorIndex]
			self.colorIndex = (self.colorIndex + 1) % colorArray.count
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
		if(self.timesAnimationLooped % 2 != 0) {
			self.graphicView.transform = CGAffineTransformScale(self.graphicView.transform, 1/1.3, 1/1.3)
		}
		timesAnimationLooped = 0
		self.isRefreshAnimating = false
		self.refreshColorView.backgroundColor = UIColor.clearColor()
		
	}
	
}
