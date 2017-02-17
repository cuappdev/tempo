//
//  FeedVC.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit
import MediaPlayer

class FeedViewController: PlayerTableViewController, SongSearchDelegate, FeedFollowSuggestionsControllerDelegate {
	
	static let readPostsKey = "FeedViewController.readPostsKey"
	
	lazy var customRefresh: ADRefreshControl = {
		self.refreshControl = UIRefreshControl()
		let customRefresh = ADRefreshControl(refreshControl: self.refreshControl!)
		self.refreshControl?.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
		return customRefresh
	}()
	
	var plusButton: UIButton!
	
	lazy var searchTableViewController: SearchViewController = {
		let vc = SearchViewController()
		vc.delegate = self
		return vc
	}()
	
	var pretappedPlusButton = false
	var refreshNeeded = false //set to true on logout
	
	var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
	
	var feedFollowSuggestionsController: FeedFollowSuggestionsController?
	
	// MARK: - Lifecycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Feed"
		view.backgroundColor = .readCellColor
		setupAddButton()
		tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		//disable user interaction when first loading up feed
		//user interaction gets enabled after refresh is done
		//not very elegant solution, but fixes some UI issues
		view.isUserInteractionEnabled = false
		
		addHamburgerMenu()
		
		tableView.tableHeaderView = nil
		tableView.rowHeight = 111
		tableView.showsVerticalScrollIndicator = false
		refreshControl = customRefresh.refreshControl
		tableView.insertSubview(refreshControl, belowSubview: tableView.getScrollView()!)
		tableView.alpha = 0.0
		
		// Add follow suggestions controller to tableView
		// Only shows if no posts in past 24 hours
		feedFollowSuggestionsController = FeedFollowSuggestionsController(frame: view.frame)
		feedFollowSuggestionsController?.delegate = self
		
		// Check for 3D Touch availability
		if #available(iOS 9.0, *) {
			if traitCollection.forceTouchCapability == .available {
				registerForPreviewing(with: self, sourceView: view)
			}
		}
		
		refreshFeedWithDelay(0, timeout: 5.0)
		activityIndicatorView.center = view.center
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Begin a post if coming from a quick action
		if pretappedPlusButton {
			plusButtonTapped()
			pretappedPlusButton = false
		} else {
			rotatePlusButton(false)
		}
		plusButton.isHidden = notConnected(false)
		feedFollowSuggestionsController?.reload()
		
		//Animate appropriate cell if feed song is already playing
		if let currentPost = playerNav.currentPost, playerNav.playingPostType == .feed {
			let rowCount = tableView.numberOfRows(inSection: 0)
			for row in 0 ..< rowCount {
				if let thisCell = tableView.cellForRow(at: NSIndexPath(row: row, section: 0) as IndexPath) as? FeedTableViewCell, thisCell.postView.post == currentPost {
					thisCell.postView.updatePlayingStatus()
					break
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if refreshNeeded { //when user re-logged in
			refreshNeeded = false
			refreshFeed()
		}
		
		let _ = notConnected(true)
	}
	
	func refreshFeedWithDelay(_ delay: Double, timeout: Double) {
		//finished refreshing gets set to true when the api returns
		var finishedRefreshing = false
		//minimum time passed gets set to true when minimum delay dispatch gets called
		var minimumTimePassed = false
		
		if tableView.alpha == 0.0 {
			activityIndicatorView.startAnimating()
			view.addSubview(activityIndicatorView)
		}
		
		feedFollowSuggestionsController?.reload()
		
		API.sharedAPI.fetchFeedOfEveryone { [weak self] (posts: [Post]) in
			DispatchQueue.main.async {
				self?.posts = posts
				//return even if we get data after a timeout
				if finishedRefreshing {
					self?.tableView.alpha = 1.0
					self?.tableView.reloadData()
					return
				} else if minimumTimePassed {
					self?.refreshControl?.endRefreshing()
					self?.view.isUserInteractionEnabled = true
					self?.tableView.reloadData()
				}
				finishedRefreshing = true
				
				if let x = self {
					if x.posts.count == 0 {
						x.feedFollowSuggestionsController?.showNoMorePostsLabel()
						x.tableView.tableFooterView = x.feedFollowSuggestionsController?.view
					} else if x.posts.count < 3 {
						x.feedFollowSuggestionsController?.hideNoMorePostsLabel()
						x.tableView.tableFooterView = x.feedFollowSuggestionsController?.view
					} else {
						x.tableView.backgroundView = nil
						x.tableView.tableFooterView = nil
					}
					x.preparePosts()
					x.continueAnimatingAfterRefresh()
				}
				
				self?.tableView.alpha = 1.0
			}

			self?.activityIndicatorView.stopAnimating()
			self?.activityIndicatorView.removeFromSuperview()
		}
		
		//fetch for a minimum of delay seconds
		//if after delay seconds we finished fetching,
		//then we reload the tableview, else we wait for the
		//api to return to reload by setting minumum time passed
		var popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: popTime) {
			if finishedRefreshing {
				Banner.hide()
				self.plusButton.isHidden = self.notConnected(false)
				self.tableView.reloadData()
				self.refreshControl?.endRefreshing()
				self.view.isUserInteractionEnabled = true
			} else {
				minimumTimePassed = true
			}
		}
		
		//timeout for refresh taking too long
		popTime = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: popTime) {
			if !finishedRefreshing {
				self.plusButton.isHidden = self.notConnected(true)
				self.refreshControl?.endRefreshing()
				self.view.isUserInteractionEnabled = true
				finishedRefreshing = true
			}
		}
	}
	
	func continueAnimatingAfterRefresh() {
		//animate currently playing song
		if let playerCellPost = self.playerNav.currentPost {
			for row in 0 ..< posts.count {
				if posts[row].equals(other: playerCellPost) {
					posts[row] = playerCellPost
					let indexPath = IndexPath(row: row, section: 0)
					if let cell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell {
						cell.postView.post = playerCellPost
						cell.postView.updatePlayingStatus()
					}
					break
				}
			}
		}
	}
	
	func refreshFeed() {
		refreshFeedWithDelay(3.0, timeout: 10.0)
	}
	
	// MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		
		let post = posts[indexPath.row]
		
		cell.postView.avatarImageView?.image = nil
		cell.postView.type = .feed
		cell.postView.post = posts[indexPath.row]
		cell.postView.postViewDelegate = self
		cell.postView.playerDelegate = self
		
		if let listenedToPosts = UserDefaults.standard.dictionary(forKey: FeedViewController.readPostsKey) as? [String:Double], listenedToPosts[post.postID] != nil {
			cell.postView.post?.player.wasPlayed = true
		}
		
		cell.setUpCell(firstName: post.user.firstName, lastName: post.user.lastName)
		
		if let currentPost = playerNav.currentPost, post.equals(other: currentPost) {
			cell.postView.updatePlayingStatus()
		}
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let post = posts[indexPath.row]
		if var listenedToPosts = UserDefaults.standard.dictionary(forKey: FeedViewController.readPostsKey) as? [String:Double] {
				
			// clear posts older than 24 hrs
			for postID in listenedToPosts.keys {
				if let timestamp = listenedToPosts[postID], Date().timeIntervalSince1970 - timestamp > 86400000 {
					listenedToPosts[postID] = nil
				}
			}
				
			listenedToPosts[post.postID] = Date().timeIntervalSince1970
			UserDefaults.standard.set(listenedToPosts, forKey: FeedViewController.readPostsKey)
		} else {
			UserDefaults.standard.set([post.postID: Date().timeIntervalSince1970], forKey: FeedViewController.readPostsKey)
		}

		currentlyPlayingIndexPath = indexPath
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		customRefresh.scrollViewDidScroll(scrollView)
	}
	
	func setupAddButton() {
		let image = #imageLiteral(resourceName: "AddIcon")
		plusButton = UIButton(type: .custom)
		plusButton.frame = CGRect(origin: .zero, size: image.size)
		plusButton.setImage(image, for: UIControlState())
		plusButton.imageView!.contentMode = .center
		plusButton.imageView!.clipsToBounds = false
		plusButton.adjustsImageWhenHighlighted = false
		plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
	}
	
	func rotatePlusButton(_ active: Bool) {
		
		if let currentTransform = plusButton.imageView!.layer.presentation()?.transform {
			plusButton.imageView?.layer.transform = currentTransform
		}
		plusButton.removeTarget(nil, action: nil, for: .allEvents)
		plusButton.addTarget(self, action: active ? #selector(dismissButtonTapped) : #selector(plusButtonTapped), for: .touchUpInside)
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			let transform = active ? CGAffineTransform(rotationAngle: CGFloat(M_PI_4)) : CGAffineTransform.identity
			self.plusButton.imageView!.transform = transform
			}, completion: nil)
	}
	
	func dismissButtonTapped() {
		searchTableViewController.dismiss()
	}
	
	func plusButtonTapped() {
		
		rotatePlusButton(true)
		
		searchTableViewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		searchTableViewController.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
		searchTableViewController.selfPostIds = posts.filter({ $0.user.name == User.currentUser.name }).map({ $0.song.spotifyID })
		playerNav.animateExpandedCell(isExpanding: false)
		navigationController?.pushViewController(searchTableViewController, animated: false)
	}
	
	// MARK: - SongSearchDelegate
	
	func didSelectSong(_ song: Song) {
		posts.insert(Post(song: song, user: User.currentUser, date: Date()), at: 0)
		API.sharedAPI.updatePost(User.currentUser.id, song: song) { [weak self] _ in
			self?.refreshFeed()
		}
	}
	
	// MARK: - Navigation
	
	func didTapImageForPostView(_ post: Post) {
		let profileVC = ProfileViewController()
		profileVC.title = "Profile"
		profileVC.user = post.user
		navigationController?.pushViewController(profileVC, animated: true)
	}
	
	func didToggleLike() {
		//if there is a currentlyPlayingIndexPath, need to sync liked status of playerCells and post
		if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
			if let cell = tableView.cellForRow(at: currentlyPlayingIndexPath) as? FeedTableViewCell {
				cell.postView.updateLikedStatus()
				playerNav.updateLikeButton()
			}
		}
	}
	
	// MARK: - FeedFollowSuggestionsDelegate
	
	func feedFollowSuggestionsController(controller: FeedFollowSuggestionsController, wantsToShowProfileForUser user: User) {
		let profileVC = ProfileViewController()
		profileVC.title = "Profile"
		profileVC.user = user
		navigationController?.pushViewController(profileVC, animated: true)
	}
	
	func feedFollowSuggestionsControllerWantsToShowMoreSuggestions() {
		navigateToSuggestions()
	}
	
	func feedFollowSuggestionsUserFollowed() {
		refreshFeed()
	}
}

@available(iOS 9.0, *)
extension FeedViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		let tableViewPoint = view.convert(location, to: tableView)
		
		guard let indexPath = tableView.indexPathForRow(at: tableViewPoint),
			let cell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell else {
				return nil
		}
		
		let postView = cell.postView
		guard let avatar = postView?.avatarImageView else { return nil }
		
		let avatarFrame = postView?.convert(avatar.frame, to: tableView)
		
		if (avatarFrame?.contains(tableViewPoint))! {
			guard let user = postView?.post?.user else { return nil }
			let peekViewController = ProfileViewController()
			peekViewController.title = "Profile"
			peekViewController.user = user
			
			peekViewController.preferredContentSize = .zero
			previewingContext.sourceRect = (postView?.convert(avatar.frame, to: tableView))!
			
			return peekViewController
		}
		return nil
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		show(viewControllerToCommit, sender: self)
	}
}

extension UITableView {
	func getScrollView() -> UIScrollView? {
		for subview in subviews {
			if subview is UIScrollView {
				return subview as? UIScrollView
			}
		}
		return nil
	}
}
