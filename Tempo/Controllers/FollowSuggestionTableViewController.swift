//
//  FollowSuggestionTableViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol SuggestedFollowersDelegate {
	func didTapFollowButton(_ cell: FollowSuggestionsTableViewCell)
}

class FollowSuggestionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SuggestedFollowersDelegate {
	
	fileprivate var users: [User] = []
	let threshold = 0 // threshold from bottom of tableView
	var isLoadingMore = false // flag
	let length = 10
	var page = 0
	var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Suggestions"
		addHamburgerMenu()
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.register(UINib(nibName: "FollowSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowSuggestionsCell")
		let completion: ([User]) -> Void = {
			self.users = $0
			self.tableView.reloadData()
		}
		API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FollowSuggestionsCell", for: indexPath) as! FollowSuggestionsTableViewCell
		
		let user = users[indexPath.row]
		cell.userName.text = "\(user.firstName) \(user.shortenLastName())"
		cell.userHandle.text = "@\(user.username)"
		cell.numFollowLabel.text = "\(user.followersCount) followers"
		cell.userImage.hnk_setImageFromURL(user.imageURL)
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
		cell.delegate = self
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		profileVC.title = "Profile"
		profileVC.user = users[indexPath.row]
		navigationController?.pushViewController(profileVC, animated: true)
	}
 
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let contentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
		if !isLoadingMore && (maximumOffset - contentOffset <= CGFloat(threshold)) {
			self.isLoadingMore = true
			let completion: ([User]) -> Void = {
				for user in $0 {
					self.users.append(user)
				}
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
				self.isLoadingMore = false
			}
			page += 1
			API.sharedAPI.fetchFollowSuggestions(completion, length: length, page: page)
		}
	}
	
	func didTapFollowButton(_ cell: FollowSuggestionsTableViewCell) -> Void {
		let indexPath = tableView.indexPath(for: cell)
		let user = users[indexPath!.row]
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRow(at: indexPath!) as! FollowSuggestionsTableViewCell
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
}
