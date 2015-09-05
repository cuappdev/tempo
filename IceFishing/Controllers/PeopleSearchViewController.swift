//
//  PeopleSearchsViewController.swift
//  Followers
//
//  Created by Joseph Antonakakis on 5/4/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class PeopleSearchViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate {

    var users: [User] = []
    //var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        //tapGesture.cancelsTouchesInView = false
        //self.view.addGestureRecognizer(tapGesture)
        
        beginIceFishing()
        
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .None
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FollowTableViewCell
        
        // Configure the cell
        let user = users[indexPath.row]
        cell.userHandle.text = user.name
        cell.userName.text = user.username
        cell.numFollowLabel.text = "\(user.followersCount) followers"
        user.loadImage {
            cell.userImage.image = $0
        }
        
        return cell as FollowTableViewCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.title = "Profile"
        profileVC.user = users[indexPath.row]
          self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}