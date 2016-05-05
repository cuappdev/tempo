//
//  SignInViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/15/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    var searchNavigationController: UINavigationController!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var vinyl: UIImageView!
    
    var shouldAnimate = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
		loginButton.layer.cornerRadius = 1.0
		loginButton.layer.masksToBounds = true
		animateRecord()
    }
    
    func animateRecord() {
        UIView.animateWithDuration(3.0, delay: 0.0, options: .CurveLinear, animations: {
            self.vinyl.transform = CGAffineTransformMakeRotation((360.0 * CGFloat(M_PI)) / 360.0)
			
        }) { (complete: Bool) in
            if self.shouldAnimate {
                self.animateRecord()
            }
        }
    }
    
    @IBAction func logIn(sender: UIButton) {
        self.shouldAnimate = false
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.loginToFacebook()
    }
    
}
