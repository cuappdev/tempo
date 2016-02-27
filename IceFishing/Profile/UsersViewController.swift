//
//  UsersViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

enum DisplayType: String {
	case Followers = "Followers"
	case Following = "Following"
	case Users = "Users"
}

class UsersViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

	var user: User = User.currentUser
	var displayType: DisplayType = .Users
	private var users: [User] = []
	private var filteredUsers: [User] = []
	private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		view.backgroundColor = UIColor.iceDarkGray
		tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
		
		// Set up search bar
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar!.textColor = UIColor.whiteColor()
		
		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.iceDarkRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
		
		// Populate users
		let completion: [User] -> Void = {
			self.users = $0
			self.tableView.reloadData()
		}
		
		switch(displayType) {
		case .Followers:
			API.sharedAPI.fetchFollowers(user.id, completion: completion)
		case .Following:
			API.sharedAPI.fetchFollowing(user.id, completion: completion)
		default:
			API.sharedAPI.searchUsers("", completion: completion)
			title = "Search Users"
			addHamburgerMenu()
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		notConnected()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
    // MARK: Table View Methods
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if users.count > 0 || displayType == .Users {
			self.tableView.backgroundView = nil
			return 1
		} else {
			let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
			var image: UIImage
			if displayType == .Following {
				image = UIImage(named: "headphonesPerson")!
			} else {
				image = UIImage(named: "greyPeople")!
			}
			
			let imageView = UIImageView(image: image)
			imageView.frame.origin = CGPoint(x: emptyView.bounds.width/2 - imageView.bounds.width/2, y: emptyView.bounds.height/2 - imageView.bounds.height/2)
			
			emptyView.addSubview(imageView)
			
			let label = UILabel(frame: CGRect(x: 0, y: imageView.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height))
			label.textColor = UIColor.whiteColor()
			label.textAlignment = .Center
			label.numberOfLines = 2
			label.font = UIFont(name: "AvenirNext-Regular", size: 16)
			
			if displayType == .Followers {
				if user.id == User.currentUser.id {
					label.text = "No followers right now\nTell your friends to follow you!"
				} else {
					label.text = "\(user.firstName) doesn't have any followers\nFollow them!"
				}
			} else {
				if user.id == User.currentUser.id {
					label.text = "Follow your Facebook friends to\nview them here!"
				} else {
					label.text = "\(user.firstName) is not following anyone"
				}
			}
			
			emptyView.addSubview(label)
			
			self.tableView.backgroundView = emptyView
		}
		
		return 0
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchController.active ? filteredUsers.count : users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
		let user = searchController.active ? filteredUsers[indexPath.row] : users[indexPath.row]

        cell.userName.text = user.name
        cell.userHandle.text = "@\(user.username)"
        cell.numFollowLabel.text = "\(user.followersCount) followers"
        user.loadImage {
            cell.userImage.image = $0
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray
		
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.title = "Profile"
		profileVC.user = searchController.active ? filteredUsers[indexPath.row] : users[indexPath.row]
		
		let backButton = UIBarButtonItem()
		backButton.title = "Search"
		navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(profileVC, animated: true)
    }
	
	// MARK: Search Methods
	
	private func filterContentForSearchText(searchText: String, scope: String = "All") {
		let pred = NSPredicate(format: "name contains[cd] %@ OR username contains[cd] %@", searchText, searchText)
		filteredUsers = (searchText == "") ? users : (users as NSArray).filteredArrayUsingPredicate(pred) as! [User]
		tableView.reloadData()
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	//This allows for the text not to be viewed behind the search bar at the top of the screen
	private let statusBarView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20))
		view.backgroundColor = UIColor.iceDarkRed
		return view
	}()
	
	func willPresentSearchController(searchController: UISearchController) {
		navigationController?.view.addSubview(statusBarView)
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}

}