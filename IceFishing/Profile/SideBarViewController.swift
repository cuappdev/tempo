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
	var viewController: UIViewController
	var image: UIImage?
	
	init(title: String, viewController: UIViewController, image: UIImage?) {
		self.title = title
		self.viewController = viewController
		self.image = image
	}
}

class SideBarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var selectionHandler: (UIViewController? -> ())?
    
    var searchNavigationController: UINavigationController!
    var elements: [SideBarElement] = []
    var button: UIButton!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var sideView: UIView!
    
    @IBAction func logOut(sender: UIButton) {
		FBSDKAccessToken.setCurrentAccessToken(nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRootVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        // Formatting
        categoryTableView.separatorStyle = .None
        categoryTableView.scrollEnabled = false
        categoryTableView.backgroundColor = UIColor.iceDarkGray
        profileView.backgroundColor = UIColor.iceDarkGray
        view.backgroundColor = UIColor.iceDarkGray
        divider.backgroundColor = UIColor.iceLightGray

		sideView.hidden = true
		sideView.backgroundColor = UIColor.iceDarkRed
		
		profilePicture.layer.masksToBounds = false
		profilePicture.layer.borderWidth = 1.5
		profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
		profilePicture.frame = CGRectMake(0, 0, 85, 85)
		profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
		profilePicture.clipsToBounds = true
		
		// Add button to profile view
		button = UIButton(type: UIButtonType.System)
		button.frame = profileView.bounds
		button.addTarget(self, action: "pushToProfile:", forControlEvents: UIControlEvents.TouchUpInside)
		view.addSubview(button)
		
		categoryTableView.reloadData()
		
		// Mark first item selected unless there was a preselected item
		if elements.count > 0 {
			if let selectedIndex = preselectedIndex {
				if selectedIndex == -1 {
					profileView.backgroundColor = .iceLightGray
					sideView.hidden = false
					categoryTableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: .None)
				} else {
					categoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), animated: false, scrollPosition: .None)
				}
				preselectedIndex = nil
			} else {
				categoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		nameLabel.text = User.currentUser.name
		usernameLabel.text = "@\(User.currentUser.username)"
		User.currentUser.loadImage {
			self.profilePicture.image = $0
		}
		
		// Mark first item selected unless there was a preselected item
		if let selectedIndex = preselectedIndex {
			if selectedIndex == -1 {
				profileView.backgroundColor = .iceLightGray
				sideView.hidden = false
				categoryTableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: .None)
			} else {
				categoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), animated: false, scrollPosition: .None)
			}
			preselectedIndex = nil
		}
	}
	
	func pushToProfile(sender:UIButton!) {
		profileView.backgroundColor = UIColor.iceLightGray
		sideView.hidden = false
		let loginVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		loginVC.user = User.currentUser
		selectionHandler?(loginVC)
		categoryTableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: .None)
	}
	
	// TableView Methods
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return elements.count
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
		profileView.backgroundColor = UIColor.clearColor()
		sideView.hidden = true
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 55
	}
	
}
