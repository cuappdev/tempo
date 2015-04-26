//
//  LoginViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var isFollowing = false
    var numFollowing: Int = 0
    var numFollowers: Int = 0
    
    var searchNavigationController: UINavigationController!

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userHandleLabel: UILabel!
    @IBOutlet weak var followButtonLabel: UIButton!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postHistoryLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = User.sharedInstance

        nameLabel.text = user.name

        userHandleLabel.text = "@\(user.username)"
        // Set FB profile picture as user picture
        if let url = NSURL(string: "http://graph.facebook.com/\(user.id)/picture?type=large") {
            if let data = NSData(contentsOfURL: url) {
                profilePictureView.image = UIImage(data: data)
            }
        }

        
        println(nameLabel.text)
        println(userHandleLabel.text)
        
        followButtonLabel.frame = CGRectMake(0, 0, 197/2, 59/2)
        numFollowersLabel.text = "\(numFollowers)"
        numFollowingLabel.text = "\(numFollowing)"
        
        if !isFollowing {
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
        } else {
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
        }
        
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderWidth = 1.5
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.frame = CGRectMake(0, 0, 150/2, 150/2)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 181/255, green: 87/255, blue: 78/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add profile button to the left side of the navbar
        var menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height * 0.65))
        menuButton.setImage(UIImage(named: "white-hamburger-menu-Icon"), forState: .Normal)
        menuButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        // Pop out sidebar when hamburger menu tapped
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Buttons
    
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
    
}

