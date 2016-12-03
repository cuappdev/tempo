//
//  HamburgerIconView.swift
//  Tempo
//
//  Created by Dennis Fedorko on 5/10/16.
//  Copyright © 2016 Dennis Fedorko. All rights reserved.
//

import UIKit
import SWRevealViewController

let RevealControllerToggledNotification = "RevealControllerToggled"

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
		
		func applyStyle(_ bar: UIView, heightMultiplier: CGFloat) {
			bar.isUserInteractionEnabled = false
			bar.center = CGPoint(x: bar.center.x, y: frame.height * heightMultiplier)
			bar.layer.cornerRadius = lineWidth * 0.5
			bar.backgroundColor = color
			bar.layer.allowsEdgeAntialiasing = true
			addSubview(bar)
		}
		                
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width * iconWidthRatio, height: lineWidth))
        middleBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width * iconWidthRatio, height: lineWidth))
        bottomBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width * iconWidthRatio, height: lineWidth))
		
		applyStyle(topBar, heightMultiplier: 0.5 - spacingRatio)
        applyStyle(middleBar, heightMultiplier: 0.5)
		applyStyle(bottomBar, heightMultiplier: 0.5 + spacingRatio)
		
		//be notified when hamburger menu opens/closes
		NotificationCenter.default.addObserver(self, selector: #selector(hamburgerMenuToggled), name: NSNotification.Name(rawValue: RevealControllerToggledNotification), object: nil)
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: -
	//MARK: User Interaction
	
	func hamburgerMenuToggled(_ notification: Notification) {
		if let revealVC = notification.object as? SWRevealViewController {
			if revealVC.frontViewController.view.isUserInteractionEnabled {
				//turn on hamburger menu
				animateToHamburger()
			} else {
				animateToClose()
			}
		}
	}
    
    func animateIcon() {
        isUserInteractionEnabled = true
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
		
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 30, options: [], animations: {
			self.middleBar.alpha = 0
			}, completion: nil)
		
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			let rotationClockWise = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
			let rotationCounterClockWise = CGAffineTransform(rotationAngle: CGFloat(-M_PI_4))
			let moveDownToCenter = CGAffineTransform(translationX: 0, y: self.frame.height * self.spacingRatio)
			let moveUpToCenter = CGAffineTransform(translationX: 0, y: -self.frame.height * self.spacingRatio)
			
			self.topBar.transform = rotationClockWise.concatenating(moveDownToCenter)
			
			self.bottomBar.transform = rotationCounterClockWise.concatenating(moveUpToCenter)
			
			}, completion: { _ in
				self.isUserInteractionEnabled = true
		})
		isHamburgerMode = false
	}
	
	func animateToHamburger() {
		if isHamburgerMode { return }
		
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 30, options: [], animations: {
			self.middleBar.alpha = 1
			}, completion: nil)
		
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			
			self.topBar.transform = CGAffineTransform.identity
			self.topBar.center = CGPoint(x: self.topBar.center.x, y: self.frame.height * (0.5 - self.spacingRatio))
			
			self.bottomBar.transform = CGAffineTransform.identity
			self.bottomBar.center = CGPoint(x: self.bottomBar.center.x, y: self.frame.height * (0.5 + self.spacingRatio))
			
			}, completion: { _ in
				self.isUserInteractionEnabled = true
		})
		isHamburgerMode = true
	}
}
