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
    let api = API.sharedAPI
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logIn(sender: UIButton) {
        
        // If there is an existing open session
        if (FBSession.activeSession().state == FBSessionState.Open || FBSession.activeSession().state == FBSessionState.OpenTokenExtended) {
            
            //let mainVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
            //self.searchNavigationController = UINavigationController(rootViewController: mainVC)
            //self.presentViewController(self.searchNavigationController, animated: false, completion: nil)
            
        } else {
            
            // Open a session with the login UI
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: {
                (session:FBSession!, state:FBSessionState, error:NSError!) in
                
                // Handle session state changes
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.sessionStateChanged(session, state: state, error: error)
                
                // Request FB user info
                if (session.isOpen) {
                    var userRequest : FBRequest = FBRequest.requestForMe()
                    userRequest.startWithCompletionHandler{(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
  
                        if (error == nil) {
                            let userName = result["name"]
                            let userID = result["id"]
                            let userEmail = result["email"]
                            
                            // Check if new user
//                            api.fetchUser(userID, completion: {(user: User) -> Void in
//                                
//                            })
                            
                            let usernameViewController = UsernameViewController(nibName: "Username", bundle: nil)
                            self.searchNavigationController = UINavigationController(rootViewController: usernameViewController)
                            self.presentViewController(self.searchNavigationController, animated: false, completion: nil)
                            
                        } else {
                            println("Error")
                        }
                    }
                }
            })
        }
        
    }
    
}
