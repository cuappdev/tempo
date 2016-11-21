//
//  FeedFollowSuggestionsController.swift
//  Tempo
//
//  Created by Dennis Fedorko on 11/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

protocol FeedFollowSuggestionsControllerDelegate: class {
	func feedFollowSuggestionsController(controller: FeedFollowSuggestionsController, wantsToShowProfileForUser user: User)
	func feedFollowSuggestionsControllerWantsToShowMoreSuggestions()
}

class FeedFollowSuggestionsController: NSObject, UITableViewDataSource, UITableViewDelegate, FollowUserDelegate {
	
	var view: UIView!
	var noMorePostsLabel: UILabel!
	var followSuggestionsLabel: UILabel!
	var tableView: UITableView!
	var showMoreSuggestionsButton: UIButton!
	var suggestedPeopleToFollow = [User]()
	var showingNoMorePostsLabel = true
	var originalFrame: CGRect!
	weak var delegate: FeedFollowSuggestionsControllerDelegate?
	
	init(frame: CGRect) {
		super.init()
		
		originalFrame = frame
		
		view = UIView(frame: frame)
				
		setupView()
		
		fetchSuggestedPeopleToFollow()
	}
	
	func hideNoMorePostsLabel() {
		if !showingNoMorePostsLabel {
			return
		}
		noMorePostsLabel.removeFromSuperview()
		
		let topInset: CGFloat = 40.0
		
		view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height - noMorePostsLabel.frame.height + topInset)
		
		followSuggestionsLabel.frame.top = CGPoint(x: followSuggestionsLabel.frame.top.x, y: followSuggestionsLabel.frame.top.y - noMorePostsLabel.frame.height + topInset)
		tableView.frame.top = CGPoint(x: tableView.frame.top.x, y: tableView.frame.top.y - noMorePostsLabel.frame.height + topInset)
		showMoreSuggestionsButton.center = CGPoint(x: view.center.x, y: tableView.frame.bottom.y + (view.frame.height - tableView.frame.bottom.y) / 2.0)
		
		showingNoMorePostsLabel = false
	}
	
	func showNoMorePostsLabel() {
		if showingNoMorePostsLabel {
			return
		}
		
		view.frame = originalFrame

		view.addSubview(noMorePostsLabel)
		
		followSuggestionsLabel.frame.top = CGPoint(x: followSuggestionsLabel.frame.top.x, y: noMorePostsLabel.frame.bottom.y)
		tableView.frame.top = CGPoint(x: tableView.frame.top.x, y: followSuggestionsLabel.frame.bottom.y + 10)
		showMoreSuggestionsButton.center = CGPoint(x: view.center.x, y: tableView.frame.bottom.y + (view.frame.height - tableView.frame.bottom.y) / 2.0)
		
		view.addSubview(noMorePostsLabel)
		
		showingNoMorePostsLabel = true
	}
	
	func reload() {
		fetchSuggestedPeopleToFollow()
	}
	
	func fetchSuggestedPeopleToFollow() {
		let completion: ([User]) -> Void = { (users: [User]) in
			DispatchQueue.main.async {
				self.suggestedPeopleToFollow = users
				self.tableView.reloadData()
				
				if self.suggestedPeopleToFollow.count == 0 {
					self.view.alpha = 0.0
				} else {
					self.view.alpha = 1.0
					self.tableView.backgroundView = nil
				}
			}
		}
		
		API.sharedAPI.fetchFollowSuggestions(completion, length: 3, page: 0)
	}
	
	func setupView() {
		noMorePostsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.225))
		noMorePostsLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
		noMorePostsLabel.text = "No posts in the last 24 hours"
		noMorePostsLabel.textColor = .white
		noMorePostsLabel.textAlignment = .center
		noMorePostsLabel.baselineAdjustment = .alignCenters
		
		followSuggestionsLabel = UILabel(frame: CGRect(x: 16, y: noMorePostsLabel.frame.bottom.y, width: view.frame.width - 32, height: 20))
		followSuggestionsLabel.font = UIFont(name: "Avenir-Light", size: 14)
		followSuggestionsLabel.text = "SUGGESTED PEOPLE TO FOLLOW"
		followSuggestionsLabel.textColor = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1.0)
		followSuggestionsLabel.textAlignment = .left
		followSuggestionsLabel.baselineAdjustment = .alignCenters
		
		tableView = UITableView(frame: CGRect(x: 16, y: followSuggestionsLabel.frame.bottom.y + 10, width: view.frame.width - 32, height: 240), style: .plain)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.isScrollEnabled = false
		tableView.rowHeight = 80
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
		
		showMoreSuggestionsButton = UIButton(type: .system)
		showMoreSuggestionsButton.frame = CGRect(x: 0, y: 0, width: 200, height: 36)
		showMoreSuggestionsButton.center = CGPoint(x: view.center.x, y: tableView.frame.bottom.y + (view.frame.height - tableView.frame.bottom.y) / 2.0)
		showMoreSuggestionsButton.backgroundColor = UIColor.tempoLightRed
		showMoreSuggestionsButton.setTitle("Follow more friends", for: UIControlState())
		showMoreSuggestionsButton.setTitleColor(UIColor.white, for: UIControlState())
		showMoreSuggestionsButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
		showMoreSuggestionsButton.layer.cornerRadius = 5.0
		showMoreSuggestionsButton.addTarget(self, action: #selector(didTapShowMoreSuggestionsButton), for: .touchUpInside)

		
		view.addSubview(noMorePostsLabel)
		view.addSubview(followSuggestionsLabel)
		view.addSubview(tableView)
		view.addSubview(showMoreSuggestionsButton)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return suggestedPeopleToFollow.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
		
		let user = suggestedPeopleToFollow[indexPath.row]
		
		cell.userName.text = user.name
		cell.userHandle.text = "@\(user.username)"
		cell.numFollowLabel.text = (user.followersCount == 1) ? "1 follower" : "\(user.followersCount) followers"
		cell.userImage.hnk_setImageFromURL(user.imageURL)
		if user.id != User.currentUser.id {
			cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
			cell.followButton.backgroundColor = (user.isFollowing) ? UIColor.tempoLightGray : UIColor.tempoLightRed
			cell.followButton.setTitleColor((user.isFollowing) ? UIColor.offWhite : UIColor.white, for: UIControlState())
			cell.delegate = self
		} else {
			cell.followButton.setTitle("", for: UIControlState())
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
		selectedCell.contentView.backgroundColor = UIColor.tempoLightGray
		
		let user = suggestedPeopleToFollow[indexPath.row]
		
		delegate?.feedFollowSuggestionsController(controller: self, wantsToShowProfileForUser: user)
	}
	
	func didTapFollowButton(_ cell: FollowTableViewCell) {
		
		guard let indexPath = tableView.indexPath(for: cell) else {
			return
		}
		
		let user = suggestedPeopleToFollow[indexPath.row]
		
		if user.id == User.currentUser.id {
			return
		}
		
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRow(at: indexPath) as! FollowTableViewCell
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
		cell.followButton.backgroundColor = (user.isFollowing) ? UIColor.tempoLightGray : UIColor.tempoLightRed
		cell.followButton.setTitleColor((user.isFollowing) ? UIColor.offWhite : UIColor.white, for: UIControlState())
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

	func didTapShowMoreSuggestionsButton() {
		delegate?.feedFollowSuggestionsControllerWantsToShowMoreSuggestions()
	}
}
