////
////  PlayerNavigationController.swift
////  Tempo
////
////  Created by Jesse Chen on 10/23/16.
////  Copyright © 2016 CUAppDev. All rights reserved.
////
//
//import UIKit
//
//let PostLikedStatusChangeNotification = "PostLikedStatusChange"
//
//protocol PostDelegate {
//	func getCurrentPost() -> Post?
//}
//
//class PlayerNavigationController: UINavigationController, PostDelegate {
//
//	private var playerCell: PlayerCellView!
//	let frameHeight: CGFloat = 72
//	
//	private var expandedCell: ExpandedPlayerView!
//	let expandedHeight: CGFloat = 347
//	
//	private var currentPost: Post? {
//		didSet {
//			if let newPost = currentPost {
//				//deal with previous post
//				oldValue?.player.progress = 0
//				oldValue?.player.pause()
//				postView?.updatePlayingStatus()
//				updatePlayerCells(newPost: newPost)
//			}
//		}
//	}
//	private var postView: PostView?
//	private var postsRef: [Post]?
//	private var postRefIndex: Int?
//	private var playerDelegate: PlayerDelegate?
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		let playerFrame = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - frameHeight, width: UIScreen.main.bounds.width, height: frameHeight))
//		playerFrame.backgroundColor = .red
//		view.addSubview(playerFrame)
//		playerCell = Bundle.main.loadNibNamed("PlayerCellView", owner: self, options: nil)?.first as? PlayerCellView
//		playerCell?.setup(parent: self)
//		playerCell?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frameHeight)
//		playerCell?.isUserInteractionEnabled = false
//		playerFrame.addSubview(playerCell!)
//		// Do any additional setup after loading the view.
//		
//		// Setup expandedCell
//		expandedCell = Bundle.main.loadNibNamed("ExpandedPlayerView", owner: self, options: nil)?.first as? ExpandedPlayerView
//		expandedCell?.setup(parent: self)
//		expandedCell?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: expandedHeight)
//		view.addSubview(expandedCell!)
//	}
//	
//	// updates all relevant information for new post and begins playing the song
//	func updateNewPost(post: Post, delegate: PlayerDelegate, postsRef: [Post]?, postRefIndex: Int?, postView: PostView?) {
//		updateDelegates(delegate: delegate)
//		currentPost = post
//		self.postsRef = postsRef
//		self.postRefIndex = postRefIndex
//		self.postView = postView
//		delegate.didTogglePlaying(animate: true)
//	}
//	
//	private func updatePlayerCells(newPost: Post) {
//		playerCell.updateCellInfo(newPost: newPost)
//		expandedCell.updateCellInfo(newPost: newPost)
//	}
//	
//	func animateExpandedCell(isExpanding: Bool) {
//		UIView.animate(withDuration: 0.2) {
//			let loc = isExpanding ? self.expandedHeight : CGFloat(0)
//			UIView.animate(withDuration: 0.2, animations: {
//				self.expandedCell.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - loc, width: UIScreen.main.bounds.width, height: self.expandedHeight)
//				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
//			})
//		}
//	}
//	
//	private func updateDelegates(delegate: PlayerDelegate) {
//		playerDelegate = delegate
//		playerCell.delegate = delegate
//		expandedCell.delegate = delegate
//	}
//	
//	func resetPlayerCells() {
//		if let currentPost = currentPost, currentPost.player.isPlaying {
//			playerDelegate?.didTogglePlaying(animate: false)
//		}
//		currentPost?.player.progress = 0.0
//		currentPost = nil
//		playerCell.resetPlayerCell()
//		expandedCell.resetPlayerCell()
//	}
//	
//	func updatePlayingStatus() {
//		playerCell.updatePlayingStatus()
//		expandedCell.updatePlayingStatus()
//	}
//	
//	func updateLikeButton() {
//		playerCell.updateLikeButton()
//		expandedCell.updateLikeButton()
//	}
//	
//	func updateAddButton() {
//		playerCell.updateAddButton()
//		expandedCell.updateAddButton()
//	}
//	
//	func togglePause() {
//		if let post = currentPost, post.player.isPlaying {
//			post.player.togglePlaying()
//			post.player.progress = 0.0
//			expandedCell.progressView.setNeedsDisplay()
//			playerCell.progressView.setNeedsDisplay()
//			postView?.updatePlayingStatus()
//			updatePlayingStatus()
//		}
//	}
//	
//	// MARK: - Getters and setters
//	
//	func getCurrentPost() -> Post? {
//		return currentPost
//	}
//	
//	func getPostView() -> PostView? {
//		return postView
//	}
//	
//	func setPostView(newPostView: PostView) {
//		postView = newPostView
//	}
//}
