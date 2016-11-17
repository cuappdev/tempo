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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loginButton.layer.cornerRadius = 5
		loginButton.layer.masksToBounds = true

    }
	
    @IBAction func logIn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loginToFacebook()
    }
}
