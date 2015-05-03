//
//  FollowersViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowersViewController: UITableViewController, UIScrollViewDelegate {
    
    // TODO: Uncomment when test user is made
    //var followers: [String]! = []
    
    // TODO: For testing purposes (delete when test user is made)
    var followers: [String] = ["Adam", "Adler", "Alexander", "Andrew", "Annie", "Ashton", "Austin", "Brendan", "Brian", "Dennis"]
    var followerHandles: [String] = ["adam", "adler", "alexander", "andrew", "annie", "ashton", "austin", "brendan", "brian", "dennis"]
    var numFollowers: [Int] = [10, 229, 38, 40, 100, 374, 2731, 384, 12, 293]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Uncomment when test user is made
        //self.followers = User.currentUser.followers
        
        tableView.backgroundColor = UIColor.iceDarkGray()
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
    
        tableView.separatorStyle = .None
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add back button to profile
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: navigationController!.navigationBar.frame.height))
        backButton.setImage(UIImage(named: "Profile-Icon"), forState: .Normal)
        backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // Return to profile view
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
        
        // TODO: For testing purposes (delete when test user is made)
        cell.userImage.image = UIImage(named: "Sexy")
        cell.userName.text = self.followers[indexPath.row]
        cell.userHandle.text = "@\(self.followerHandles[indexPath.row])"
        cell.numFollowLabel.text = "\(self.numFollowers[indexPath.row]) followers"
        
        // TODO: Uncomment when test user is made
        //        if let url = NSURL(string: "http://graph.facebook.com/\(self.followers[indexPath.row].fbid)/picture?type=large") {
        //            if let data = NSData(contentsOfURL: url) {
        //                cell.userImage.image = UIImage(data: data)
        //            }
        //        }
        //        cell.userName.text = self.followers[indexPath.row].name
        //        cell.userHandle.text = "@\(self.followers[indexPath.row].username)"
        //        cell.numFollowLabel.text = "\(self.followers[indexPath.row].followersCount) followers"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray()
        
        // TODO: Push to user's profile view
    }
}