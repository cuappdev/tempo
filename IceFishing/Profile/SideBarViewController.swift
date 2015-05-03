//
//  SideBarViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

struct SideBarElement {
    var title: String
    var viewController: UIViewController?
    var image: UIImage?
    
    init(title: String, viewController: UIViewController?, image: UIImage?) {
        self.title = title
        self.viewController = viewController
        self.image = image
    }
}

class SideBarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBLoginViewDelegate {
    var selectionHandler: (UIViewController? -> ())?
    
    var searchNavigationController: UINavigationController!
    var elements: [SideBarElement] = []

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var divider: UIView!
    
    @IBAction func logOut(sender: UIButton) {
        FBSession.activeSession().closeAndClearTokenInformation()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRootVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        // Formatting
        categoryTableView.separatorStyle = .None
        categoryTableView.scrollEnabled = false
        categoryTableView.backgroundColor = UIColor.iceDarkGray()
        profileView.backgroundColor = UIColor.iceDarkGray()
        self.view.backgroundColor = UIColor.iceDarkGray()
        divider.backgroundColor = UIColor.iceLightGray()
        
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
        
        categoryTableView.reloadData()
        // mark first item selected cuz it is
        if (elements.count > 0) {
            categoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = User.currentUser.name
        usernameLabel.text = "@\(User.currentUser.username)"
        if let url = NSURL(string: "http://graph.facebook.com/\(User.currentUser.fbid)/picture?type=large") {
            if let data = NSData(contentsOfURL: url) {
                profilePicture.image = UIImage(data: data)
            }
        }
    }
    
    func pushToProfile(sender:UIButton!) {
        if (searchNavigationController == nil) {
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            searchNavigationController = UINavigationController(rootViewController: loginVC)
        }
//        presentViewController(searchNavigationController, animated: false, completion: nil)
        selectionHandler?(searchNavigationController)
        self.categoryTableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: .None)
    }
    
    func dismiss(sender:UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! SideBarTableViewCell
        let element = elements[indexPath.row]
        
        cell.categorySymbol.image = element.image
        cell.categoryLabel.text = element.title
        
        return cell
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let element = elements[indexPath.row]
        selectionHandler?(element.viewController)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(55)
    }

}
