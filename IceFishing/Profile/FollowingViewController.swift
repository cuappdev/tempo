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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowersCell")
        
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: navigationController!.navigationBar.frame.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 181/255, green: 87/255, blue: 78/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.following.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowersCell", forIndexPath: indexPath) as FollowersTableViewCell
        
        cell.userImage.image = UIImage(named: "Steven")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(following[indexPath.row])")
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 19/255, green: 39/255, blue: 49/255, alpha: 1)
    }
    
}
