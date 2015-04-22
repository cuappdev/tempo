//
//  LoginViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    var isFollowing = false
    var numFollowing: Int = 0
    var numFollowers: Int = 0
    
    @IBOutlet var fbLoginView: FBLoginView!
    @IBOutlet var profilePictureView: FBProfilePictureView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet weak var followButtonLabel: UIButton!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postHistoryLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    
    @IBAction func followButton(sender: UIButton) {
        if (!isFollowing) {
            isFollowing = true
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
            numFollowers = numFollowers + 1
        } else {
            isFollowing = false
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
            numFollowers = numFollowers - 1
        }
        numFollowersLabel.text = "\(numFollowers)"
    }
    
    @IBAction func followersButton(sender: UIButton) {
        let followersVC = FollowersViewController()
        followersVC.title = "Followers"
        let navController = UINavigationController(rootViewController: followersVC)
        self.presentViewController(navController, animated: true, completion: nil)
    }

    @IBAction func followingButton(sender: UIButton) {
        let followingVC = FollowingViewController()
        followingVC.title = "Following"
        let navController = UINavigationController(rootViewController: followingVC)
        self.presentViewController(navController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
//        if FBSession.activeSession().isOpen {
//            let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
//            self.navigationController?.pushViewController(profileVC, animated: true)
//        }
        
        followButtonLabel.frame = CGRectMake(0, 0, 197/2, 59/2)
        numFollowersLabel.text = "\(numFollowers)"
        numFollowingLabel.text = "\(numFollowing)"
        
        if !isFollowing {
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
        } else {
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
        }
        
        self.profilePictureView.hidden = true
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderWidth = 1.5
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.frame = CGRectMake(0, 0, 150/2, 150/2)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true
        
        /*var feedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: navigationController!.navigationBar.frame.height))
        feedButton.setTitle("Feed", forState: .Normal)
        feedButton.addTarget(self, action: "pushToFeed", forControlEvents: .TouchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: feedButton)*/
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 181/255, green: 87/255, blue: 78/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func pushToFeed() {
        self.navigationController?.pushViewController(FeedViewController(), animated: true)
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        self.profilePictureView.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser) {
        var userEmail = user.objectForKey("email") as! String
        
        self.profilePictureView.hidden = false
        self.profilePictureView.profileID = user.objectID
        self.nameLabel.text = user.name
        self.usernameLabel.text = "@" + user.objectID
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        
        FBSession.activeSession().closeAndClearTokenInformation()
        self.profilePictureView.hidden = true
        self.profilePictureView.profileID = nil
        self.nameLabel.text = ""
        self.usernameLabel.text = ""
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
}

