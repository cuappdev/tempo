//
//  PlayerCenter.swift
//  Tempo
//
//  Created by Jesse Chen on 3/26/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Foundation

protocol PostDelegate {
	func getCurrentPost() -> Post?
}

class PlayerCenter: TabBarAccessoryViewController, PostDelegate, NotificationDelegate {
	
	static let sharedInstance = PlayerCenter()
	
	private var playerCell: PlayerCellView!
	let miniHeight: CGFloat = 72
	var viewMiniFrame: CGRect!
	
	private var expandedCell: ExpandedPlayerView!
	let expandedHeight: CGFloat = 347
	var viewExpandedFrame: CGRect!
	
	private var currentPost: Post? {
		didSet {
			if let newPost = currentPost {
				//deal with previous post
				oldValue?.player.progress = 0
				oldValue?.player.pause()
				postView?.updatePlayingStatus()
				updatePlayerCells(newPost: newPost)
			}
		}
	}
	private var postView: PostView?
	private var postsRef: [Post]?
	private var postRefIndex: Int?
	private var playerDelegate: PlayerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewMiniFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - miniHeight - tabBarHeight, width: UIScreen.main.bounds.width, height: miniHeight)
		viewExpandedFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - expandedHeight - tabBarHeight, width: UIScreen.main.bounds.width, height: expandedHeight)
		
		playerCell = Bundle.main.loadNibNamed("PlayerCellView", owner: self, options: nil)?.first as? PlayerCellView
		playerCell?.setup(parent: self)
		playerCell?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: miniHeight)
		playerCell?.isUserInteractionEnabled = false
		
		// Setup expandedCell
		expandedCell = Bundle.main.loadNibNamed("ExpandedPlayerView", owner: self, options: nil)?.first as? ExpandedPlayerView
		expandedCell?.setup(parent: self)
		expandedCell?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: expandedHeight)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		view.frame = viewMiniFrame
		view.addSubview(playerCell)
		view.addSubview(expandedCell)
	}
	
	// updates all relevant information for new post and begins playing the song
	func updateNewPost(post: Post, delegate: PlayerDelegate, postsRef: [Post]?, postRefIndex: Int?, postView: PostView?) {
		updateDelegates(delegate: delegate)
		currentPost = post
		self.postsRef = postsRef
		self.postRefIndex = postRefIndex
		self.postView = postView
		delegate.didTogglePlaying(animate: true)
	}
	
	private func updatePlayerCells(newPost: Post) {
		playerCell.updateCellInfo(newPost: newPost)
		expandedCell.updateCellInfo(newPost: newPost)
	}
	
	func animateExpandedCell(isExpanding: Bool) {
		UIView.animate(withDuration: 0.2) {
			let offset = isExpanding ? CGFloat(0) : UIScreen.main.bounds.height
			self.view.frame = isExpanding ? self.viewExpandedFrame : self.viewMiniFrame
			UIView.animate(withDuration: 0.2, animations: {
				self.expandedCell.frame = CGRect(x: 0, y: offset, width: UIScreen.main.bounds.width, height: self.expandedHeight)
				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
				self.playerCell.alpha = isExpanding ? 0 : 1
				self.expandedCell.alpha = isExpanding ? 1 : 0
			})
		}
	}
	
	private func updateDelegates(delegate: PlayerDelegate) {
		playerDelegate = delegate
		playerCell.delegate = delegate
		expandedCell.delegate = delegate
	}
	
	func resetPlayerCells() {
		if let currentPost = currentPost, currentPost.player.isPlaying {
			playerDelegate?.didTogglePlaying(animate: false)
		}
		currentPost?.player.progress = 0.0
		currentPost = nil
		playerCell.resetPlayerCell()
		expandedCell.resetPlayerCell()
	}
	
	func updatePlayingStatus() {
		playerCell.updatePlayingStatus()
		expandedCell.updatePlayingStatus()
	}
	
	func updateLikeButton() {
		playerCell.updateLikeButton()
		expandedCell.updateLikeButton()
	}
	
	func updateAddButton() {
		playerCell.updateAddButton()
		expandedCell.updateAddButton()
	}
	
	func togglePause() {
		if let post = currentPost, post.player.isPlaying {
			post.player.togglePlaying()
			post.player.progress = 0.0
			expandedCell.progressView.setNeedsDisplay()
			playerCell.progressView.setNeedsDisplay()
			postView?.updatePlayingStatus()
			updatePlayingStatus()
		}
	}
	
	// MARK: - Getters and setters
	
	func getCurrentPost() -> Post? {
		return currentPost
	}
	
	func getPostView() -> PostView? {
		return postView
	}
	
	func setPostView(newPostView: PostView) {
		postView = newPostView
	}
	
	override func expandAccessoryViewController(animated: Bool) {
		animateExpandedCell(isExpanding: true)
	}
	
	override func collapseAccessoryViewController(animated: Bool) {
		animateExpandedCell(isExpanding: false)
	}
	
	// MARK: - Notification Delegate Method
	
	// MARK: Banner Methods
	func showNotificationBanner(_ userInfo: [AnyHashable : Any]) {
		let info = (userInfo[AnyHashable("custom")] as! NSDictionary).value(forKey: "a") as! NSDictionary
		
		if info.value(forKey: "notification_type") as! Int == 1 {
			// Liked song notification
			Banner.showBanner(
				self,
				delay: 0.5,
				data: TempoNotification(msg: info.value(forKey: "message") as! String, type: .Like),
				backgroundColor: .white,
				textColor: .black,
				delegate: self)
		} else if info.value(forKey: "notification_type") as! Int == 2 {
			// New user follower
			let custom = userInfo[AnyHashable("custom")] as! NSDictionary
			let info = custom.value(forKey: "a") as! NSDictionary
			Banner.showBanner(
				self,
				delay: 0.5,
				data: TempoNotification(msg: info.value(forKey: "message") as! String, type: .Follower),
				backgroundColor: .white,
				textColor: .black,
				delegate: self)
		} else {
			// Generic notification - do nothing
			return
		}
	}
	
	func didTapNotification(forNotification notif: TempoNotification, cell: NotificationTableViewCell?, postHistoryVC: PostHistoryTableViewController?) {
		
		if let postID = notif.postId, notif.type == .Like, let vc = postHistoryVC {
			var row: Int = 0
			for p in vc.posts {
				if p.postID == postID { break }
				row += 1
			}
			vc.sectionIndex = vc.relativeIndexPath(row: row).section
			self.show(vc, sender: nil)
		} else if notif.type == .Follower, let user = notif.user {
			let profileVC = ProfileViewController()
			profileVC.title = "Profile"
			profileVC.user = user
			self.show(profileVC, sender: nil)
		}
	}
}
