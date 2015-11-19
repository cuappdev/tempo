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
}

class UsersViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

	var user: User = User.currentUser
	var displayType: DisplayType = .Followers
	private var users: [User] = []
	private var filteredUsers: [User] = []
	
	private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
		
        tableView.registerNib(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		
		//Formating for search Bar
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar!.textColor = UIColor.whiteColor()

		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		tableView.tableHeaderView = searchController.searchBar
		tableView.backgroundView = UIView() // Fix color above search bar
		
		let completion: [User] -> Void = {
			self.users = $0
			self.tableView.reloadData()
		}
		
		if displayType == .Followers {
			API.sharedAPI.fetchFollowers(user.id, completion: completion)
		} else {
			API.sharedAPI.fetchFollowing(user.id, completion: completion)
		}
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.active {
			return self.filteredUsers.count
		} else {
			return self.users.count
		}
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
        
        var user = users[indexPath.row]
		if searchController.active {
			user = filteredUsers[indexPath.row]
			
		}

        cell.userName.text = user.name
        cell.userHandle.text = "@\(user.username)"
        cell.numFollowLabel.text = "\(user.followersCount) followers"
        user.loadImage {
            cell.userImage.image = $0
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.title = "Profile"
		if searchController.active {
			profileVC.user = filteredUsers[indexPath.row]
		} else {
			profileVC.user = users[indexPath.row]
		}
        navigationController?.pushViewController(profileVC, animated: true)
    }
	
	private func filterContentForSearchText(searchText: String, scope: String = "All") {
		if searchText == "" {
			filteredUsers = users
		} else {
			let pred = NSPredicate(format: "name contains[cd] %@ OR username contains[cd] %@", searchText, searchText)
			filteredUsers = (users as NSArray).filteredArrayUsingPredicate(pred) as! [User]
		}
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
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}