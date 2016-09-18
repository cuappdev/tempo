//
//  SideBarViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKShareKit

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
	
	var preselectedIndex: Int? // -1 is profile
    
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
		appDelegate.feedVC.refreshNeeded = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        // Formatting
        categoryTableView.separatorStyle = .None
        categoryTableView.scrollEnabled = false
        categoryTableView.backgroundColor = UIColor.tempoDarkGray
        profileView.backgroundColor = UIColor.tempoDarkGray
        view.backgroundColor = UIColor.tempoDarkGray
        divider.backgroundColor = UIColor.tempoLightGray

		sideView.hidden = true
		sideView.backgroundColor = UIColor.tempoLightRed
		
		profilePicture.frame = CGRectMake(0, 0, 85, 85)
		profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
		profilePicture.clipsToBounds = true
		
		// Add button to profile view
		button = UIButton(type: UIButtonType.System)
		button.frame = profileView.bounds
		button.addTarget(self, action: #selector(pushToProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		view.addSubview(button)
		
		categoryTableView.reloadData()
		
		// Mark first item selected unless there was a preselected item
		if elements.count > 0 {
			if let selectedIndex = preselectedIndex {
				if selectedIndex == -1 {
					profileView.backgroundColor = .tempoLightGray
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
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
		
		// Mark first item selected unless there was a preselected item
		if let selectedIndex = preselectedIndex {
			if selectedIndex == -1 {
				profileView.backgroundColor = .tempoLightGray
				sideView.hidden = false
				categoryTableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: .None)
			} else {
				categoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0), animated: false, scrollPosition: .None)
			}
			preselectedIndex = nil
		}
	}
	
	func pushToProfile(sender:UIButton!) {
		profileView.backgroundColor = UIColor.tempoLightGray
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
