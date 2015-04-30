//
//  LoginViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, HipCalendarViewDelegate {
    
    var isFollowing = false
    var numFollowing: Int = 0
    var postedDates: [NSDate]! = []
    
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
    @IBOutlet weak var postCalendarView: HipCalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = User.currentUser.name
        userHandleLabel.text = "@\(User.currentUser.username)"
        if let url = NSURL(string: "http://graph.facebook.com/\(User.currentUser.fbid)/picture?type=large") {
            if let data = NSData(contentsOfURL: url) {
                profilePictureView.image = UIImage(data: data)
            }
        }

        followButtonLabel.frame = CGRectMake(0, 0, 197/2, 59/2)
        numFollowersLabel.text = "\(User.currentUser.followersCount)"
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
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Post history calendar
        postCalendarView.initialize()
        
        // Add refresh scroll button for calendar
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = self.postHistoryLabel.frame
        button.addTarget(self, action: "refreshScroll", forControlEvents: UIControlEvents.TouchUpInside)
        self.postCalendarView.addSubview(button)
        
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
    
    func refreshScroll() {
        self.postCalendarView.reloadInputViews()
        println("reload")
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Buttons
    
    @IBAction func followButton(sender: UIButton) {
        if (!isFollowing) {
            isFollowing = true
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
            User.currentUser.followersCount = User.currentUser.followersCount + 1
        } else {
            isFollowing = false
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
            User.currentUser.followersCount = User.currentUser.followersCount - 1
        }
        numFollowersLabel.text = "\(User.currentUser.followersCount)"
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
    
    // HipCalendarViewDelegate Methods
    
    func hipCalendarView(hipCalendarView: HipCalendarView, didSelectDate date: NSDate) {
        println("Selected \(date)")
        let postHistoryVC = PostHistoryTableViewController(nibName: "PostHistoryTableViewController", bundle: nil)
        //postHistoryVC.postedDates = dates
        self.presentViewController(postHistoryVC, animated: false, completion: nil)
    }
    
    func hipCalendarView(hipCalendarView: HipCalendarView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath)
    }
    
    
    
}

