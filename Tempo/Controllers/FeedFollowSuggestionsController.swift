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
	
	let suggestionsEdgePadding: CGFloat = 16
	let topInset: CGFloat = 40
	let smallerYOffset: CGFloat = 22
	let greaterYOffset: CGFloat = 123
	let cellHeight: CGFloat = 101
	let numFollowSuggestions: Int = 3
	
	var view: UIView!
	var suggestionsContainerView: UIView!
	var noMorePostsLabel: UILabel!
	var tableView: UITableView!
	
	var suggestedPeopleToFollow = [User]()
	var showingNoMorePostsLabel: Bool = true
	var suggestionsContainerHeight: CGFloat!
	
	weak var delegate: FeedFollowSuggestionsControllerDelegate?
	
	init(frame: CGRect) {
		super.init()

		view = UIView(frame: frame)
		setupView()
		fetchSuggestedPeopleToFollow()
	}
	
	func showNoMorePostsLabel() {
		if showingNoMorePostsLabel { return }
		
		view.addSubview(noMorePostsLabel)
		showingNoMorePostsLabel = true
		updateViews()
	}
	
	func hideNoMorePostsLabel() {
		if !showingNoMorePostsLabel { return }
		
		noMorePostsLabel.removeFromSuperview()
		showingNoMorePostsLabel = false
		updateViews()
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
		
		API.sharedAPI.fetchFollowSuggestions(completion, length: numFollowSuggestions, page: 0)
	}
	
	func setupView() {
		// Create no posts in last 24 hours label
		noMorePostsLabel = UILabel(frame: CGRect(x: 0, y: 65, width: view.frame.width, height: 23))
		noMorePostsLabel.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		noMorePostsLabel.text = "No posts in the last 24 hours."
		noMorePostsLabel.textColor = .descriptionGrey
		noMorePostsLabel.textAlignment = .center
		noMorePostsLabel.isHidden = !showingNoMorePostsLabel
		
		// Create suggestions container view
		let currContainerYOffset = showingNoMorePostsLabel ? greaterYOffset : smallerYOffset
		let followSuggestionsLabelHeight: CGFloat = 18
		let tableViewHeight: CGFloat = cellHeight * CGFloat(numFollowSuggestions)
		let followMoreButtonHeight: CGFloat = 36
		suggestionsContainerHeight = followSuggestionsLabelHeight + suggestionsEdgePadding/2 + tableViewHeight + suggestionsEdgePadding + followMoreButtonHeight
		
		suggestionsContainerView = UIView(frame: CGRect(x: 0, y: currContainerYOffset, width: view.bounds.width, height: suggestionsContainerHeight))

		let followSuggestionsLabel = UILabel(frame: CGRect(x: suggestionsEdgePadding, y: 0, width: view.frame.width - 2*suggestionsEdgePadding, height: 18))
		followSuggestionsLabel.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
		followSuggestionsLabel.text = "SUGGESTED PEOPLE TO FOLLOW"
		followSuggestionsLabel.textColor = .sectionTitleGrey
		followSuggestionsLabel.textAlignment = .left
		
		tableView = UITableView(frame: CGRect(x: suggestionsEdgePadding, y: followSuggestionsLabel.frame.maxY + suggestionsEdgePadding/2, width: view.frame.width - 2*suggestionsEdgePadding, height: tableViewHeight), style: .plain)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = cellHeight
		tableView.isScrollEnabled = false
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCell")
		
		let followMoreButton = UIButton(frame: CGRect(x: 0, y: tableView.frame.maxY + suggestionsEdgePadding, width: 200, height: 36))
		followMoreButton.center.x = view.center.x
		followMoreButton.backgroundColor = .tempoRed
		followMoreButton.setTitle("Follow more friends", for: UIControlState())
		followMoreButton.setTitleColor(UIColor.white.withAlphaComponent(0.87), for: UIControlState())
		followMoreButton.titleLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 16.0)
		followMoreButton.layer.cornerRadius = 3
		followMoreButton.addTarget(self, action: #selector(didTapFollowMoreButton), for: .touchUpInside)

		view.addSubview(noMorePostsLabel)
		suggestionsContainerView.addSubview(followSuggestionsLabel)
		suggestionsContainerView.addSubview(tableView)
		suggestionsContainerView.addSubview(followMoreButton)
		view.addSubview(suggestionsContainerView)
		
		let viewHeight = currContainerYOffset + suggestionsContainerHeight + smallerYOffset
		view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: viewHeight)
	}
	
	func updateViews() {
		noMorePostsLabel.isHidden = !showingNoMorePostsLabel
		suggestionsContainerView.frame.origin.y = showingNoMorePostsLabel ? greaterYOffset : smallerYOffset
		
		let viewHeight = suggestionsContainerView.frame.minY + suggestionsContainerHeight + smallerYOffset
		view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: viewHeight)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return suggestedPeopleToFollow.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
		
		let user = suggestedPeopleToFollow[indexPath.row]
		
		cell.userName.text = "\(user.firstName) \(user.shortenLastName())"
		cell.userHandle.text = "@\(user.username)"
		cell.numFollowLabel.text = (user.followersCount == 1) ? "1 follower" : "\(user.followersCount) followers"
		cell.userImage.hnk_setImageFromURL(user.imageURL)
		
		if user.id != User.currentUser.id {
			cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
			cell.followButton.backgroundColor = (user.isFollowing) ? .clear : .tempoRed
			cell.followButton.setTitleColor((user.isFollowing) ? .redTintedWhite : .followLightRed, for: UIControlState())
			cell.delegate = self
		} else {
			cell.followButton.setTitle("", for: UIControlState())
		}
		
		cell.setUpFollowSuggestionsCell()
		cell.setUpInitialsView(firstName: user.firstName, lastName: user.lastName)
		cell.setNeedsLayout()
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = suggestedPeopleToFollow[indexPath.row]
		
		delegate?.feedFollowSuggestionsController(controller: self, wantsToShowProfileForUser: user)
	}
	
	func didTapFollowButton(_ cell: FollowTableViewCell) {
		
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		
		let user = suggestedPeopleToFollow[indexPath.row]
		
		if user.id == User.currentUser.id { return }
		
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		let cell = tableView.cellForRow(at: indexPath) as! FollowTableViewCell
		cell.followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
		cell.followButton.backgroundColor = (user.isFollowing) ? .clear : .tempoRed
		cell.followButton.setTitleColor((user.isFollowing) ? .redTintedWhite : .followLightRed, for: UIControlState())
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

	func didTapFollowMoreButton() {
		delegate?.feedFollowSuggestionsControllerWantsToShowMoreSuggestions()
	}
}
