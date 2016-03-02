//
//  FollowSuggestionTableViewController.swift
//  IceFishing
//
//  Created by Jesse Chen on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol SuggestedFollowersDelegate {
	func didTapFollowButton(cell: FollowSuggestionsTableViewCell)
}

class FollowSuggestionTableViewController: UITableViewController, SuggestedFollowersDelegate {
	
	private var users: [User] = []
	let threshold = 0 // threshold from bottom of tableView
	var isLoadingMore = false // flag
	let length = 10
	var page = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Suggestions"
		addHamburgerMenu()
		tableView.registerNib(UINib(nibName: "FollowSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowSuggestionsCell")
		let completion: [User] -> Void = {
			self.users = $0
			self.tableView.reloadData()
		}
		API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FollowSuggestionsCell", forIndexPath: indexPath) as! FollowSuggestionsTableViewCell
		
		let user = users[indexPath.row]
		cell.userName.text = user.name
		cell.userHandle.text = "@\(user.username)"
		cell.numFollowLabel.text = "\(user.followersCount) followers"
		user.loadImage {
			cell.userImage.image = $0
		}
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", forState: .Normal)
		cell.delegate = self
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		profileVC.title = "Profile"
		profileVC.user = users[indexPath.row]
		navigationController?.pushViewController(profileVC, animated: true)
	}
 
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		let contentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
		if !isLoadingMore && (maximumOffset - contentOffset <= CGFloat(threshold)) {
			self.isLoadingMore = true
			let completion: [User] -> Void = {
				for user in $0 {
					self.users.append(user)
				}
				dispatch_async(dispatch_get_main_queue()) {
					self.tableView.reloadData()
				}
				self.isLoadingMore = false
			}
			page += 1
			API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
		}
	}
	
	func didTapFollowButton(cell: FollowSuggestionsTableViewCell) -> Void {
		let indexPath = tableView.indexPathForCell(cell)
		let user = users[indexPath!.row]
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRowAtIndexPath(indexPath!) as! FollowSuggestionsTableViewCell
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", forState: .Normal)
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
}
