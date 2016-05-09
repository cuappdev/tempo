//
//  ProfilePictureViewController.swift
//  IceFishing
//
//  Created by Monica Ong on 2/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ProfilePictureViewController: UIViewController {
	
    @IBOutlet weak var profilePictureView: UIImageView!
	private let pan = UIPanGestureRecognizer()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		pan.addTarget(self, action: #selector(moveProPic(_:)))
		profilePictureView.addGestureRecognizer(pan)
		profilePictureView.userInteractionEnabled = true
    }
	
    @IBAction func exitButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	func moveProPic(sender: UIPanGestureRecognizer){
		let trans = sender.translationInView(self.view)
		profilePictureView.center = CGPoint(x: profilePictureView.center.x, y: profilePictureView.center.y + trans.y)
		if sender.state == UIGestureRecognizerState.Ended{
			finishSwiping(fabs(self.view.bounds.midY - profilePictureView.center.y))
		}
		sender.setTranslation(CGPointZero, inView: self.view)
	}
	
	func finishSwiping(verticalTranslation: CGFloat){
		if verticalTranslation <= 30 {
			UIView.animateWithDuration(0.5) {
				self.profilePictureView.center.y = self.view.bounds.midY
			}
		} else {
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
}
