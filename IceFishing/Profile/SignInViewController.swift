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
        FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: {
            (session:FBSession!, state:FBSessionState, error:NSError!) in
            
            // Handle session state changes
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.sessionStateChanged(session, state: state, error: error)
            
            // Request FB user info
            if (session.isOpen) {
                API.sharedAPI.getCurrentUser() { user in
                    println(user)
                    
                    let usernameVC = UsernameViewController(nibName: "Username", bundle: nil)
                    self.presentViewController(usernameVC, animated: false, completion: nil)
                    
                    // TODO: Uncomment when user saved in NSUserDefaults
//                    API.sharedAPI.usernameIsValid(User.currentUser.username) { success in
//                        if (success) {
//                            let usernameVC = UsernameViewController(nibName: "Username", bundle: nil)
//                            self.presentViewController(usernameVC, animated: false, completion: nil)
//                        } else {
//                             let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                             appDelegate.toggleRootVC()
//                        }
//                    }
                }
                
            }
        })
        
    }
    
}
