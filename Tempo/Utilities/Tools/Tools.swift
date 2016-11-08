//
//  Tools.swift
//
//  Created by Dennis Fedorko on 4/22/15.
//  Copyright (c) 2015 Dennis F. All rights reserved.
//

import UIKit
import Tweaks

class Tools: UIView, FBTweakViewControllerDelegate {
	
	var screenCapture: ADScreenCapture!
	var popup: UIAlertController!
	var rootViewController: UIViewController!
	var fbTweaks: FBTweakViewController!
	var displayingTweaks = false
	var keyboardIsShowing = false
	
	init(rootViewController: UIViewController, slackChannel: String, slackToken: String, slackUsername: String) {
		super.init(frame: rootViewController.view.frame)
		
		self.rootViewController = rootViewController
		isUserInteractionEnabled = false
		
		//create view that will be responsible for screen capture
		screenCapture = ADScreenCapture(frame: rootViewController.view.frame)
		rootViewController.view.addSubview(screenCapture)
		rootViewController.view.addSubview(self)
		
		//create UIAlertController to display options on shake gesture
		popup = UIAlertController(title: "Tools", message: nil, preferredStyle: .actionSheet)
		
		//create message action option
		let submitMessage = UIAlertAction(title: "Submit Message", style: .default) { _ in
			let vc = SubmitBugViewController(toolsController: self, channel: slackChannel, token: slackToken, username: slackUsername)
			self.rootViewController.present(vc, animated: true, completion: nil)
		}
		popup.addAction(submitMessage)
		
		//create screenshot action option
		let submitScreenshot = UIAlertAction(title: "Submit Screenshot", style: .default) { _ in
			let vc = SubmitBugViewController(toolsController: self, screenshot: self.screenCapture.getScreenshot(), channel: slackChannel, token: slackToken, username: slackUsername)
			self.rootViewController.present(vc, animated: true, completion: nil)
		}
		popup.addAction(submitScreenshot)
		
		//create tweaks action option
		let openTweaks = UIAlertAction(title: "Tweaks", style: .default) { _ in
			if !self.displayingTweaks {
				self.fbTweaks = FBTweakViewController(store: FBTweakStore.sharedInstance())
				self.fbTweaks.tweaksDelegate = self
				self.rootViewController.present(self.fbTweaks, animated: true) {
					self.displayingTweaks = true
				}
			}
		}
		popup.addAction(openTweaks)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			//dismiss popup
		}
		popup.addAction(cancelAction)
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(assignFirstResponder), name: NSNotification.Name(rawValue: "AssignToolsAsFirstResponder"), object: nil)
		becomeFirstResponder()
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name:NSNotification.Name.UIKeyboardWillShow , object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDismissed), name:NSNotification.Name.UIKeyboardWillHide , object: nil)
	}
	
	func keyboardShown() {
		keyboardIsShowing = true
	}
	
	func keyboardDismissed() {
		keyboardIsShowing = false
	}
	
	func assignFirstResponder() {
		if !keyboardIsShowing {
			becomeFirstResponder()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			rootViewController.present(popup, animated: true, completion: nil)
		}
	}
	
	func tweakViewControllerPressedDone(_ tweakViewController: FBTweakViewController!) {
		tweakViewController.dismiss(animated: true) {
			self.assignFirstResponder()
			self.displayingTweaks = false
		}
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
}
