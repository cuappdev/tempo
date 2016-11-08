//
//  SignInViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 4/15/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    var searchNavigationController: UINavigationController!
	var shouldAnimate = true

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var vinyl: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loginButton.layer.cornerRadius = 5
		loginButton.layer.masksToBounds = true
		animateRecord()
    }
    
    func animateRecord() {
        UIView.animate(withDuration: 3, delay: 0, options: .curveLinear, animations: {
            self.vinyl.transform = CGAffineTransform(rotationAngle: (360.0 * CGFloat(M_PI)) / 360.0)
			
        }) { (complete: Bool) in
            if self.shouldAnimate {
                self.animateRecord()
            }
        }
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        self.shouldAnimate = false
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.loginToFacebook()
    }
}