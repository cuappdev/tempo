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
    
    @IBAction func logOut(sender: UIButton) {
        FBSession.activeSession().closeAndClearTokenInformation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = UIImage(named: "Sexy")
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.frame = CGRectMake(0, 0, 85, 85)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
        profilePicture.clipsToBounds = true
        
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = self.profileView.bounds
        button.addTarget(self, action: "pushToProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)

        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
    }
    
    func pushToProfile(sender:UIButton!) {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        var feedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        feedButton.setImage(UIImage(named: "white-hamburger-menu-Icon"), forState: .Normal)
        feedButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        loginViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: feedButton)
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        revealViewController().panGestureRecognizer()

        searchNavigationController = UINavigationController(rootViewController: loginViewController)
        presentViewController(searchNavigationController, animated: false, completion: nil)
    }
    
    func dismiss(sender:UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! SideBarTableViewCell
        
        cell.categorySymbol.image = UIImage(named: self.symbols[indexPath.row])
        cell.categoryLabel.text = self.categories[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(55)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 43/255, green: 73/255, blue: 90/255, alpha: 1)
        
        if (indexPath.row == 0) {
//            let feedVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
//            presentViewController(feedVC, animated: false, completion: nil)
        } else if (indexPath.row == 1) {
            
        } else if (indexPath.row == 2) {
            
        } else {
            
        }
        
    }

}
