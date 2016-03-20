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
		pan.addTarget(self, action: "moveProPic:")
		profilePictureView.addGestureRecognizer(pan)
		profilePictureView.userInteractionEnabled = true
    }
	
    @IBAction func exitButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	func moveProPic(sender: UIPanGestureRecognizer){
		let trans = sender.translationInView(self.view)
		let originalYPos = self.view.frame.height/2.0
		profilePictureView.center = CGPoint(x: profilePictureView.center.x, y: profilePictureView.center.y + trans.y)
		if sender.state == UIGestureRecognizerState.Ended{
			finishSwiping(fabs(originalYPos - profilePictureView.center.y))
		}
		sender.setTranslation(CGPointZero, inView: self.view)
	}
	
	func finishSwiping(verticalTranslation: CGFloat){
		if verticalTranslation <= 30{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.profilePictureView.center.y = self.view.frame.height/2.0
			})
		}else{
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}

}
