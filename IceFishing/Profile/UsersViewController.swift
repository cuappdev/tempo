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

class UsersViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, FollowUserDelegate {

	var user: User = User.currentUser
	var displayType: DisplayType = .Users
	private var users: [User] = []
	private var suggestedUsers: [User] = []
	private var filteredUsers: [User] = []
	private var searchController: UISearchController!
	var isLoadingMoreSuggestions = false
	let length = 10
	var page = 0

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
			if self.displayType == .Users {
				self.suggestedUsers = $0
			} else {
				self.users = $0
			}
			self.tableView.reloadData()
			
			// find count of which array table view will display, if .Users then we initially display suggestedUsers
			let itemCount = (self.displayType == .Users ? self.suggestedUsers.count : self.users.count)
			
			if itemCount == 0 {
				switch self.displayType {
				case .Followers:
					self.tableView.backgroundView = UIView.viewForEmptyViewController(.Followers, size: self.view.bounds.size, isCurrentUser: (self.user.id == User.currentUser.id), userFirstName: self.user.firstName)
				case .Following:
					self.tableView.backgroundView = UIView.viewForEmptyViewController(.Following, size: self.view.bounds.size, isCurrentUser: (self.user.id == User.currentUser.id), userFirstName: self.user.firstName)
				default:
					self.tableView.backgroundView = UIView.viewForEmptyViewController(.Users, size: self.view.bounds.size, isCurrentUser: (self.user.id == User.currentUser.id), userFirstName: self.user.firstName)
				}
			} else {
				self.tableView.backgroundView = nil
			}
		}
		
		switch(displayType) {
		case .Followers:
			API.sharedAPI.fetchFollowers(user.id, completion: completion)
		case .Following:
			API.sharedAPI.fetchFollowing(user.id, completion: completion)
		default:
			API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
			title = "Search Users"
			addHamburgerMenu()
		}
		
		// Check for 3D Touch availability
		if #available(iOS 9.0, *) {
			if traitCollection.forceTouchCapability == .Available {
				registerForPreviewingWithDelegate(self, sourceView: view)
			}
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		notConnected()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
    // MARK: Table View Methods
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if displayType == .Users {
			return searchController.active ? filteredUsers.count : suggestedUsers.count
		} else {
			return searchController.active ? filteredUsers.count : users.count
		}
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell", forIndexPath: indexPath) as! FollowTableViewCell
		var user: User
		if displayType == .Users {
			user = searchController.active ? filteredUsers[indexPath.row] : suggestedUsers[indexPath.row]
		} else {
			user = searchController.active ? filteredUsers[indexPath.row] : users[indexPath.row]
		}
		
        cell.userName.text = user.name
        cell.userHandle.text = "@\(user.username)"
        cell.numFollowLabel.text = "\(user.followersCount) followers"
        user.loadImage {
            cell.userImage.image = $0
        }
		cell.followButton.setTitle(self.user.isFollowing ? "Following" : "Follow", forState: .Normal)
		cell.delegate = self
        
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
		if self.displayType == .Users {
			profileVC.user = searchController.active ? filteredUsers[indexPath.row] : suggestedUsers[indexPath.row]
		} else {
			profileVC.user = searchController.active ? filteredUsers[indexPath.row] : users[indexPath.row]
		}
		
		let backButton = UIBarButtonItem()
		backButton.title = "Search"
		navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(profileVC, animated: true)
    }
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		if !searchController.active {
			let contentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
			if (!isLoadingMoreSuggestions && maximumOffset - contentOffset <= CGFloat(0)) {
				let completion: [User] -> Void = {
					for user in $0 {
						self.suggestedUsers.append(user)
					}
					dispatch_async(dispatch_get_main_queue()) {
						self.tableView.reloadData()
					}
					self.isLoadingMoreSuggestions = false
				}
				
				page += 1
				self.isLoadingMoreSuggestions = true
				API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
			}
		}
	}
	
	// MARK: Follow User Method
	
	func didTapFollowButton(cell: FollowTableViewCell) -> Void {
		let indexPath = tableView.indexPathForCell(cell)
		
		var user: User
		if displayType == .Users {
			user = searchController.active ? filteredUsers[indexPath!.row] : suggestedUsers[indexPath!.row]
		} else {
			user = searchController.active ? filteredUsers[indexPath!.row] : users[indexPath!.row]
		}
		
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRowAtIndexPath(indexPath!) as! FollowTableViewCell
		cell.followButton.setTitle(self.user.isFollowing ? "Following" : "Follow", forState: .Normal)
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
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
		// if a .Users VC, only suggestions were fetched in viewDidLoad(), need to fetch users to search
		if displayType == .Users {
			let completion: [User] -> Void = {
				self.users = $0
				self.tableView.reloadData()
				self.filterContentForSearchText("")
			}
			
			API.sharedAPI.searchUsers("", completion: completion)
		}
		
		navigationController?.view.addSubview(statusBarView)
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}
	
}

@available(iOS 9.0, *)
extension UsersViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		let tableViewPoint = view.convertPoint(location, toView: tableView)
		
		guard let indexPath = tableView.indexPathForRowAtPoint(tableViewPoint),
			cell = tableView.cellForRowAtIndexPath(indexPath) as? FollowTableViewCell else {
				return nil
		}
		
		let peekViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		peekViewController.title = "Profile"
		peekViewController.user = searchController.active ? filteredUsers[indexPath.row] : users[indexPath.row]
		
		peekViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = tableView.convertRect(cell.frame, toView: view)
		
		return peekViewController
	}
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		let backButton = UIBarButtonItem()
		backButton.title = "Search"
		navigationItem.backBarButtonItem = backButton
		showViewController(viewControllerToCommit, sender: self)
	}
}