//
//  SignInViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/15/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    // Delete cookies
    func fbDidLogOut() {
        var cookie: NSHTTPCookie
        var storage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                var domainName: NSString = cookie.domain
                var domainRange: NSRange = domainName.rangeOfString("facebook")
                if (domainRange.length > 0) {
                    storage.deleteCookie(cookie as! NSHTTPCookie)
                }
            }
        }
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User Logged In")

    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        println("Username: \(user.username)")
        var userEmail = user.objectForKey("email") as! String
        println("User Email: \(userEmail)")

    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User Logged Out")
        fbDidLogOut()
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}
