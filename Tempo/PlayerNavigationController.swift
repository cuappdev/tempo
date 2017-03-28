//
//  PlayerNavigationController.swift
//  Tempo
//
//  Created by Jesse Chen on 10/23/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

let PostLikedStatusChangeNotification = "PostLikedStatusChange"

protocol PostDelegate {
	var currentPost: Post? { get }
}

class PlayerNavigationController: UINavigationController, PostDelegate, NotificationDelegate {

	private var playerCell: PlayerCellView!
	let frameHeight: CGFloat = 72
	
	private var expandedCell: ExpandedPlayerView!
	let expandedHeight: CGFloat = 347
	
	var currentPost: Post? {
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
	var postView: PostView?
	var postsRef: [Post]?
	var postRefIndex: Int?
	var playerDelegate: PlayerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - frameHeight, width: UIScreen.main.bounds.width, height: frameHeight))
		playerFrame.backgroundColor = .red
		view.addSubview(playerFrame)
		playerCell = Bundle.main.loadNibNamed("PlayerCellView", owner: self, options: nil)?.first as? PlayerCellView
		playerCell?.setup(parent: self)
		playerCell?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frameHeight)
		playerCell?.isUserInteractionEnabled = false
		playerFrame.addSubview(playerCell!)
		// Do any additional setup after loading the view.
		
		// Setup expandedCell
		expandedCell = Bundle.main.loadNibNamed("ExpandedPlayerView", owner: self, options: nil)?.first as? ExpandedPlayerView
		expandedCell?.setup(parent: self)
		expandedCell?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: expandedHeight)
		view.addSubview(expandedCell!)
	}
	
	func updatePlayerCells(newPost: Post) {
		playerCell.updateCellInfo(newPost: newPost)
		expandedCell.updateCellInfo(newPost: newPost)
	}
	
	func animateExpandedCell(isExpanding: Bool) {
		UIView.animate(withDuration: 0.2) {
			let loc = isExpanding ? self.expandedHeight : CGFloat(0)
			UIView.animate(withDuration: 0.2, animations: {
				self.expandedCell.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - loc, width: UIScreen.main.bounds.width, height: self.expandedHeight)
				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
			})
		}
	}
	
	func updateDelegates(delegate: PlayerDelegate) {
		playerDelegate = delegate
		playerCell.delegate = delegate
		expandedCell.delegate = delegate
	}
	
	func resetPlayerCells() {
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
			self.pushViewController(vc, animated: true)
		} else if notif.type == .Follower {
			let profileVC = ProfileViewController()
			profileVC.title = "Profile"
			if let userID = notif.userId {
				API.sharedAPI.fetchUser(userID) {
					profileVC.user = $0
					self.pushViewController(profileVC, animated: true)
				}
			}
		}
	}
}
