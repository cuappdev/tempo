//
//  LoginViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var fbLoginView: FBLoginView!
    @IBOutlet var profilePictureView: FBProfilePictureView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        self.profilePictureView.hidden = true
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderWidth = 3.0
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.frame = CGRectMake(0, 0, 150, 150)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User Logged In")
        
        self.profilePictureView.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        println("Username: \(user.username)")
        var userEmail = user.objectForKey("email") as! String
        println("User Email: \(userEmail)")
        
        self.profilePictureView.hidden = false
        self.profilePictureView.profileID = user.objectID
        self.nameLabel.text = user.name
        self.emailLabel.text = userEmail
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User Logged Out")
        
        FBSession.activeSession().closeAndClearTokenInformation()
        self.profilePictureView.hidden = true
        self.profilePictureView.profileID = nil
        self.nameLabel.text = ""
        self.emailLabel.text = ""
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}
