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
	var logoView: AnimatedLogoView!
	var isRefreshAnimating = false
	var pullDistance: CGFloat = 0
	var needsReset = false
	
	init(refreshControl: UIRefreshControl) {
		
		self.refreshControl = refreshControl
		
		createLogoView()
		
		// Hide the original spinner icon
		refreshControl.tintColor = UIColor.clear
	}
	
	func createLogoView() {
		
		// Create the graphic image views
		logoView = AnimatedLogoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), style: .refresh, showsCircle: false, showsBackground: false)
		logoView.center = CGPoint(x: refreshControl.frame.width / 2.0, y: refreshControl.frame.height / 2.0)
		logoView.isUserInteractionEnabled = false
		logoView.layer.opacity = 0
		
		// Add the graphics to the loading view
		refreshControl.addSubview(logoView)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		// Get the current size of the refresh controller
		var refreshBounds = refreshControl.bounds
		
		// Distance the table has been pulled >= 0
		let newPullDistance = max(0, -refreshControl.frame.origin.y)
		
		pullDistance = newPullDistance
		
		if pullDistance == 0 {
			needsReset = false
		}
		
		if needsReset {
			return
		}
		
		// Animate logoView opacity when initially appearing/fading
		logoView.layer.opacity = isRefreshAnimating ? 1.0 : Float(pullDistance-10.0)/45.0
		
		logoView.center = CGPoint(x: refreshBounds.size.width/2.0, y: pullDistance/2.0)
		
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
		
		logoView.animate(withDelay: 0.0, completion: {
			if self.refreshControl.isRefreshing {
				self.animateRefreshView()
			} else {
				self.resetAnimation()
			}
		})
		
	}
	
	func resetAnimation() {
		
		needsReset = true
		
		UIView.animate(withDuration: 0.1, animations: {
			self.logoView.alpha = 0.0
			self.logoView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		}, completion: { _ in
			self.logoView.removeFromSuperview()
			self.createLogoView()
		})
		
		isRefreshAnimating = false
	}
	
}
