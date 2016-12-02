//
//  UsersViewController.swift
//  Tempo
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

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, FollowUserDelegate {

	var tableView: UITableView!
	var user: User = User.currentUser
	var displayType: DisplayType = .Users
	fileprivate var users: [User] = []
	fileprivate var suggestedUsers: [User] = []
	fileprivate var filteredUsers: [User] = []
	fileprivate var searchController: UISearchController!
	var isLoadingMoreSuggestions = false
	let length = 10
	var page = 0
	
	var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		view.backgroundColor = UIColor.tempoDarkGray
		tableView.rowHeight = 80
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
		self.view.addSubview(tableView)
		
		// Set up search bar
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		searchController.searchBar.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .search, state: UIControlState())
		searchController.searchBar.setImage(#imageLiteral(resourceName: "ClearSearchIcon"), for: .clear, state: UIControlState())
		let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
		textFieldInsideSearchBar!.textColor = UIColor.white
		textFieldInsideSearchBar?.backgroundColor = UIColor.tempoDarkRed
		textFieldInsideSearchBar?.font = UIFont(name: "Avenir-Book", size: 14)
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = UIColor.tempoUltraLightRed
		
		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.tempoLightRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
		
		activityIndicatorView.center = view.center
		
		if displayType == .Users {
			title = "Search Users"
			addHamburgerMenu()
			populateSuggestions()
		} else {
			
			showActivityIndicator()
			
			let completion: ([User]) -> Void = {
				self.users = $0
				self.tableView.reloadData()
				if self.users.count == 0 {
					let contentType = self.displayType == .Followers ? ContentType.Followers : ContentType.Following
					self.tableView.backgroundView = UIView.viewForEmptyViewController(contentType, size: self.view.bounds.size, isCurrentUser: (self.user.id == User.currentUser.id), userFirstName: self.user.firstName)
				}
				
				self.hideActivityIndicator()
			}
			
			if displayType == .Followers {
				API.sharedAPI.fetchFollowers(user.id, completion: completion)
			} else {
				API.sharedAPI.fetchFollowing(user.id, completion: completion)
			}
		}
		
		// Check for 3D Touch availability
		if #available(iOS 9.0, *) {
			if traitCollection.forceTouchCapability == .available {
				registerForPreviewing(with: self, sourceView: view)
			}
		}
    }
	
	func showActivityIndicator() {
		if tableView.numberOfRows(inSection: 0) == 0 {
			activityIndicatorView.startAnimating()
			view.addSubview(activityIndicatorView)
		}
	}
	
	func hideActivityIndicator() {
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.removeFromSuperview()
	}
	
	func populateSuggestions() {
		
		showActivityIndicator()
		
		let completion: ([User]) -> Void = {
			self.suggestedUsers = $0
			self.tableView.reloadData()
			
			if self.suggestedUsers.count == 0 {
				self.tableView.backgroundView = UIView.viewForEmptyViewController(.Users, size: self.view.bounds.size, isCurrentUser: (self.user.id == User.currentUser.id), userFirstName: self.user.firstName)
			} else {
				self.tableView.backgroundView = nil
			}
			
			self.hideActivityIndicator()
		}
		
		page = 0 // reset page
		API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.tableHeaderView = notConnected(true) ? nil : searchController.searchBar
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if !searchController.isActive && displayType == .Users {
			populateSuggestions()
		}
	}
	
    // MARK: Table View Methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if displayType == .Users {
			return searchController.isActive ? users.count : suggestedUsers.count
		} else {
			return searchController.isActive ? filteredUsers.count : users.count
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
		var user: User
		if displayType == .Users {
			user = searchController.isActive ? users[indexPath.row] : suggestedUsers[indexPath.row]
		} else {
			user = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
		}
		
        cell.userName.text = "\(user.firstName) \(user.shortenLastName())"
        cell.userHandle.text = "@\(user.username)"
		cell.numFollowLabel.text = (user.followersCount == 1) ? "1 follower" : "\(user.followersCount) followers"
		cell.userImage.hnk_setImageFromURL(user.imageURL)
		if user.id != User.currentUser.id {
			cell.followButton.alpha = 1.0
			cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
			cell.followButton.backgroundColor = (user.isFollowing) ? UIColor.tempoLightGray : UIColor.tempoLightRed
			cell.followButton.setTitleColor((user.isFollowing) ? UIColor.offWhite : UIColor.white, for: UIControlState())
			cell.delegate = self
		} else {
			cell.followButton.alpha = 0.0
		}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.tempoLightGray
		
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.title = "Profile"
		if self.displayType == .Users {
			profileVC.user = searchController.isActive ? users[indexPath.row] : suggestedUsers[indexPath.row]
		} else {
			profileVC.user = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
		}
		
		let backButton = UIBarButtonItem()
		backButton.title = "Search"
		navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(profileVC, animated: true)
    }
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !searchController.isActive {
			let contentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
			if (!isLoadingMoreSuggestions && maximumOffset - contentOffset <= CGFloat(0)) {
				let completion: ([User]) -> Void = {
					for user in $0 {
						self.suggestedUsers.append(user)
					}
					DispatchQueue.main.async {
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
	
	func didTapFollowButton(_ cell: FollowTableViewCell) -> Void {
		let indexPath = tableView.indexPath(for: cell)
		
		var user: User
		if displayType == .Users {
			user = searchController.isActive ? users[indexPath!.row] : suggestedUsers[indexPath!.row]
		} else {
			user = searchController.isActive ? filteredUsers[indexPath!.row] : users[indexPath!.row]
		}
		
		if user.id == User.currentUser.id {
			return
		}
		
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRow(at: indexPath!) as! FollowTableViewCell
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
		cell.followButton.backgroundColor = (user.isFollowing) ? UIColor.tempoLightGray : UIColor.tempoLightRed
		cell.followButton.setTitleColor((user.isFollowing) ? UIColor.offWhite : UIColor.white, for: UIControlState())
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	// MARK: Search Methods
	
	fileprivate func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		let pred = NSPredicate(format: "name contains[cd] %@ OR username contains[cd] %@", searchText, searchText)
		filteredUsers = (searchText == "") ? users : (users as NSArray).filtered(using: pred) as! [User]
		tableView.reloadData()
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		self.tableView.reloadData()
		
		if displayType == .Users {
			let completion: ([User]) -> Void = {
				self.users = $0
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
			
			API.sharedAPI.searchUsers(searchController.searchBar.text!, completion: completion)
		} else {
			filterContentForSearchText(searchController.searchBar.text!)
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	// This allows for the text not to be viewed behind the search bar at the top of the screen
	fileprivate let statusBarView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
		view.backgroundColor = .tempoRed
		return view
	}()
	
	func willPresentSearchController(_ searchController: UISearchController) {
		// if a .Users VC, only suggestions were fetched in viewDidLoad(), need to fetch users to search
		navigationController?.view.addSubview(statusBarView)
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}
	
}

@available(iOS 9.0, *)
extension UsersViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		let tableViewPoint = view.convert(location, to: tableView)
		
		guard let indexPath = tableView.indexPathForRow(at: tableViewPoint),
			let cell = tableView.cellForRow(at: indexPath) as? FollowTableViewCell else {
				return nil
		}
		
		let peekViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		peekViewController.title = "Profile"
		peekViewController.user = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
		
		peekViewController.preferredContentSize = CGSize.zero
		previewingContext.sourceRect = tableView.convert(cell.frame, to: view)
		
		return peekViewController
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		let backButton = UIBarButtonItem()
		backButton.title = "Search"
		navigationItem.backBarButtonItem = backButton
		show(viewControllerToCommit, sender: self)
	}
}
