//
//  PeopleSearchsViewController.swift
//  Followers
//
//  Created by Joseph Antonakakis on 5/4/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class PeopleSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate {

    var tableView: UITableView!
    var navBar: UINavigationBar!
    let NAV_BAR_HEIGHT: CGFloat = 100
    var searchBar: UITextField!
    var xButton: UIButton!
    var users: [User] = []
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        tableView = UITableView(frame: CGRect(x: 0, y: NAV_BAR_HEIGHT, width: self.view.frame.width, height: self.view.frame.height-NAV_BAR_HEIGHT))
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NAV_BAR_HEIGHT))
        
        API.sharedAPI.searchUsers("s", completion: { users in
            
        })
        

        
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.iceDarkGray()
        
        
        // Reload the table
        self.tableView.reloadData()
        self.view.addSubview(tableView)
        navBar.barTintColor = UIColor.iceDarkRed()
        navBar.tintColor = UIColor.iceDarkRed()
        navBar.barStyle = .Black
        view.addSubview(navBar)
        
        searchBar = UITextField(frame: CGRect(x: 0, y: 0, width: navBar.frame.width*0.66, height: navBar.frame.height/2))
        searchBar.center = navBar.center
        searchBar.textColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIColor.iceDarkRed()
        searchBar.placeholder = "Type a name of your friend!"
        searchBar.textAlignment = NSTextAlignment.Center
        searchBar.delegate = self
        searchBar.addTarget(self, action: "search:", forControlEvents: UIControlEvents.EditingChanged)
        navBar.addSubview(searchBar)
        
        
        xButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        xButton.setTitle("+", forState: UIControlState.Normal)
        xButton.titleLabel?.font = UIFont.systemFontOfSize(36)
        xButton.titleLabel?.textColor = UIColor.whiteColor()
        xButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 8.0, 0.0);
        xButton.addTarget(self, action: "xButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        self.xButton.transform = transform
        xButton.center = CGPoint(x: 25, y: navBar.center.y)
        navBar.addSubview(xButton)
    
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FollowTableViewCell
        
        // Configure the cell
        cell.userHandle.text = users[indexPath.row].name
        cell.userName.text = users[indexPath.row].username
        return cell as FollowTableViewCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func xButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    func search(sender: UITextField) {
        if (searchBar.text == "") {
            users = []
            self.tableView.reloadData()
        }
        else {
            API.sharedAPI.searchUsers(searchBar.text.lowercaseString, completion: { users in
                self.users = users
                println("In here")
                self.tableView.reloadData()
            })
        }
    }
    

    


}


