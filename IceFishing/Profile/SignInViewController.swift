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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logIn(sender: UIButton) {
            
        // Open a session with the login UI
        FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true) {
            session, state, error in
            
            // Handle session state changes
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.sessionStateChanged(session, state: state, error: error)
        }
        
    }
    
}
