//
//  FollowersViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowersViewController: UITableViewController, UIScrollViewDelegate {

    var followers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: For testing purposes (delete when test user is made)
        API.sharedAPI.searchUsers("a") { users in
            self.followers = users
            self.tableView.reloadData()
        }
        
        tableView.backgroundColor = UIColor.iceDarkGray()
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
    
        tableView.separatorStyle = .None
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add back button to profile
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height))
        backButton.setImage(UIImage(named: "Close-Icon"), forState: .Normal)
        backButton.addTarget(self, action: "popToPrevious", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // Return to previous view
    func popToPrevious() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
        
        if let url = NSURL(string: "http://graph.facebook.com/\(self.followers[indexPath.row].fbid)/picture?type=large") {
            if let data = NSData(contentsOfURL: url) {
                cell.userImage.image = UIImage(data: data)
            }
        }
        cell.userName.text = self.followers[indexPath.row].name
        cell.userHandle.text = "@\(self.followers[indexPath.row].username)"
        cell.numFollowLabel.text = "\(self.followers[indexPath.row].followersCount) followers"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray()
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.title = "Profile"
        profileVC.otherUser = followers[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}