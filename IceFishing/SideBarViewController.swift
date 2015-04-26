//
//  SideBarViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SideBarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBLoginViewDelegate {
    
    var categories: [String] = ["Feed", "People", "Liked", "Spotify"]
    var symbols: [String] = ["Gray-Feed-Icon", "People-Icon", "Liked-Icon", "Music-Icon"]
    var searchNavigationController: UINavigationController!

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var divider: UIView!
    
    @IBAction func logOut(sender: UIButton) {
        FBSession.activeSession().closeAndClearTokenInformation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        // Formatting 
        categoryTableView.separatorStyle = .None
        categoryTableView.scrollEnabled = false
        categoryTableView.backgroundColor = UIColor.iceDarkGray()
        profileView.backgroundColor = UIColor(red: CGFloat(35/255.0), green: CGFloat(36/255.0), blue: CGFloat(39/255.0), alpha: 1.0)
        self.view.backgroundColor = UIColor(red: CGFloat(35/255.0), green: CGFloat(36/255.0), blue: CGFloat(39/255.0), alpha: 1.0)
        divider.backgroundColor = UIColor.iceLightGray()
        
        profilePicture.image = UIImage(named: "Sexy")
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.frame = CGRectMake(0, 0, 85, 85)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
        profilePicture.clipsToBounds = true
        
        // Add button to profile view
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = self.profileView.bounds
        button.addTarget(self, action: "pushToProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func pushToProfile(sender:UIButton!) {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        searchNavigationController = UINavigationController(rootViewController: loginViewController)
        presentViewController(searchNavigationController, animated: false, completion: nil)
    }
    
    func dismiss(sender:UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! SideBarTableViewCell
        
        cell.categorySymbol.image = UIImage(named: self.symbols[indexPath.row])
        cell.categoryLabel.text = self.categories[indexPath.row]
        
        return cell
    }
   
// TODO!
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(55)
    }

}
