//
//  FollowingViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowingViewController: UITableViewController, UIScrollViewDelegate {
    
    var followingPics: [String]!
    var following: [String] = ["Derrick", "Eric", "Feifan", "Ilan", "John", "Joe", "Karim", "Lucas", "Manuela", "Mark", "Nicole", "Sam", "Steven", "Tsvi"]
    var followingHandles: [String] = ["derrick", "eric", "feifan", "ilan", "john", "joe", "karim", "lucas", "manuela", "mark", "nicole", "sam", "steven", "tsvi"]
    var numFollowing: [Int] = [10, 229, 38, 40, 100, 374, 2731, 384, 12, 293, 34, 3, 120, 3992]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = User.sharedInstance
        
        tableView.backgroundColor = UIColor(red: 43/255, green: 73/255, blue: 90/255, alpha: 1)
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
        
        tableView.separatorStyle = .None
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 181/255, green: 87/255, blue: 78/255, alpha: 1)
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
        return self.following.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
        cell.userImage.image = UIImage(named: "Steven")
        cell.userName.text = self.following[indexPath.row]
        cell.userHandle.text = "@\(self.followingHandles[indexPath.row])"
        cell.numFollowLabel.text = "\(self.numFollowing[indexPath.row]) followers"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(following[indexPath.row])")
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 19/255, green: 39/255, blue: 49/255, alpha: 1)
    }
    
}
