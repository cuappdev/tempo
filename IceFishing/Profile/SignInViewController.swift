//
//  SignInViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/15/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func logIn(sender: UIButton) {
        if (FBSession.activeSession().state == FBSessionState.Open || FBSession.activeSession().state == FBSessionState.OpenTokenExtended)
        {
            FBSession.activeSession().closeAndClearTokenInformation()
        }
        else
        {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: {
                (session:FBSession!, state:FBSessionState, error:NSError!) in
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                appDelegate.sessionStateChanged(session, state: state, error: error)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User Logged In")

    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as! String
        println("User Email: \(userEmail)")

    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}
