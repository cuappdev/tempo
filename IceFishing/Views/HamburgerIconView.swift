//
//  HamburgerIconView.swift
//  xButton
//
//  Created by Dennis Fedorko on 5/10/16.
//  Copyright © 2016 Dennis Fedorko. All rights reserved.
//

import UIKit
import SWRevealViewController

let RevealControllerToggledNotificaiton = "RevealControllerToggled"

class HamburgerIconView: UIButton {
    
    var topBar: UIView!
    var middleBar: UIView!
    var bottomBar: UIView!
    var isHamburgerMode = true
    let spacingRatio: CGFloat = 0.2
	
	//MARK: -
	//MARK: Init

    init(frame: CGRect, color: UIColor, lineWidth: CGFloat, iconWidthRatio: CGFloat) {
        super.init(frame: frame)
		
		func applyStyle(bar: UIView, heightMultiplier: CGFloat) {
			bar.userInteractionEnabled = false
			bar.center = CGPointMake(bar.center.x, frame.height * heightMultiplier)
			bar.layer.cornerRadius = lineWidth * 0.5
			bar.backgroundColor = color
			bar.layer.allowsEdgeAntialiasing = true
			addSubview(bar)
		}
		                
        topBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
        middleBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
        bottomBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
		
		applyStyle(topBar, heightMultiplier: 0.5 - spacingRatio)
        applyStyle(middleBar, heightMultiplier: 0.5)
		applyStyle(bottomBar, heightMultiplier: 0.5 + spacingRatio)
		
		//be notified when hamburger menu opens/closes
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(hamburgerMenuToggled), name: RevealControllerToggledNotificaiton, object: nil)
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: -
	//MARK: User Interaction
	
	func hamburgerMenuToggled(notification: NSNotification) {
		if let revealVC = notification.object as? SWRevealViewController {
			if revealVC.frontViewController.view.userInteractionEnabled {
				//turn on hamburger menu
				animateToHamburger()
			} else {
				animateToClose()
			}
		}
	}
    
    func animateIcon() {
        userInteractionEnabled = true
        if isHamburgerMode {
            animateToClose()
			isHamburgerMode = false
        } else {
            animateToHamburger()
			isHamburgerMode = true
        }
    }
	
	func animateToClose() {
		if !isHamburgerMode { return }
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 30, options: [], animations: {
			self.middleBar.alpha = 0
			}, completion: nil)
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			let rotationClockWise = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
			let rotationCounterClockWise = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
			let moveDownToCenter = CGAffineTransformMakeTranslation(0, self.frame.height * self.spacingRatio)
			let moveUpToCenter = CGAffineTransformMakeTranslation(0, -self.frame.height * self.spacingRatio)
			
			self.topBar.transform = CGAffineTransformConcat(rotationClockWise, moveDownToCenter)
			
			self.bottomBar.transform = CGAffineTransformConcat(rotationCounterClockWise, moveUpToCenter)
			
			}, completion: { _ in
				self.userInteractionEnabled = true
		})
		isHamburgerMode = false
	}
	
	func animateToHamburger() {
		if isHamburgerMode { return }
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 30, options: [], animations: {
			self.middleBar.alpha = 1
			}, completion: nil)
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			self.topBar.transform = CGAffineTransformIdentity
			self.topBar.center = CGPointMake(self.topBar.center.x, self.frame.height * (0.5 - self.spacingRatio))
			
			self.bottomBar.transform = CGAffineTransformIdentity
			self.bottomBar.center = CGPointMake(self.bottomBar.center.x, self.frame.height * (0.5 + self.spacingRatio))
			
			}, completion: { _ in
				self.userInteractionEnabled = true
		})
		isHamburgerMode = true
	}
}
