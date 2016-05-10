//
//  HamburgerIconView.swift
//  xButton
//
//  Created by Dennis Fedorko on 5/10/16.
//  Copyright © 2016 Dennis Fedorko. All rights reserved.
//

import UIKit
import SWRevealViewController

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
		                
        topBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
        middleBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
        bottomBar = UIView(frame: CGRectMake(0, 0, frame.width * iconWidthRatio, lineWidth))
        
        topBar.userInteractionEnabled = false
        middleBar.userInteractionEnabled = false
        bottomBar.userInteractionEnabled = false
        
        topBar.center = CGPointMake(topBar.center.x, frame.height * (0.5 - spacingRatio))
        middleBar.center = CGPointMake(middleBar.center.x, frame.height * 0.5)
        bottomBar.center = CGPointMake(bottomBar.center.x, frame.height * (0.5 + spacingRatio))
        
        topBar.layer.cornerRadius = lineWidth * 0.5
        middleBar.layer.cornerRadius = lineWidth * 0.5
        bottomBar.layer.cornerRadius = lineWidth * 0.5
        
        topBar.backgroundColor = color
        middleBar.backgroundColor = color
        bottomBar.backgroundColor = color

        topBar.layer.allowsEdgeAntialiasing = true
        middleBar.layer.allowsEdgeAntialiasing = true
        bottomBar.layer.allowsEdgeAntialiasing = true

        addSubview(topBar)
        addSubview(middleBar)
        addSubview(bottomBar)
		
		//be notified when hamburger menu opens/closes
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HamburgerIconView.hamburgerMenuToggled), name: "Reveal Controller Toggled", object: nil)
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
			self.middleBar.alpha = 0.0
			}, completion: nil)
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			let rotationClockWise = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
			let rotationCounterClockWise = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
			let moveDownToCenter = CGAffineTransformMakeTranslation(0, self.frame.height * self.spacingRatio)
			let moveUpToCenter = CGAffineTransformMakeTranslation(0, -self.frame.height * self.spacingRatio)
			
			self.topBar.transform = CGAffineTransformConcat(rotationClockWise, moveDownToCenter)
			
			self.bottomBar.transform = CGAffineTransformConcat(rotationCounterClockWise, moveUpToCenter)
			
			}, completion: { (success: Bool) in
				self.userInteractionEnabled = true
		})
		isHamburgerMode = false
	}
	
	func animateToHamburger() {
		if isHamburgerMode { return }
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 30, options: [], animations: {
			self.middleBar.alpha = 1.0
			}, completion: nil)
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			self.topBar.transform = CGAffineTransformIdentity
			self.topBar.center = CGPointMake(self.topBar.center.x, self.frame.height * (0.5 - self.spacingRatio))
			
			self.bottomBar.transform = CGAffineTransformIdentity
			self.bottomBar.center = CGPointMake(self.bottomBar.center.x, self.frame.height * (0.5 + self.spacingRatio))
			
			}, completion: { (success: Bool) in
				self.userInteractionEnabled = true
		})
		isHamburgerMode = true
	}
}
