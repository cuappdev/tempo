//
//  FeedPostView.swift
//  Tempo
//
//  Created by Keivan Shahida on 2/22/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit
import MediaPlayer
import Haneke

class FeedPostView: PostView {
	fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
	fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
	@IBOutlet var profileNameLabel: UILabel?
	@IBOutlet var avatarImageView: UIImageView?
	@IBOutlet var descriptionLabel: UILabel?
	@IBOutlet var dateLabel: UILabel?
//	@IBOutlet var spacingConstraint: NSLayoutConstraint?
	@IBOutlet var likesLabel: UILabel?
	@IBOutlet var likedButton: UIButton?
	@IBOutlet var addButton: UIButton?
	
	let fillColor = UIColor.tempoDarkGray
 
	var type: ViewType = .feed
	var songStatus: SavedSongStatus = .notSaved
	var postViewDelegate: PostViewDelegate!
	var playerDelegate: PlayerDelegate!
	
	var playerController: PlayerTableViewController?
	
	override var post: Post? {
		didSet {
			if let post = post {
				switch type {
				case .feed:
					profileNameLabel?.text = "\(post.user.firstName) \(post.user.shortenLastName())"
					descriptionLabel?.text = "\(post.song.title)\n\(post.song.artist)"
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "LikedButton" : "LikeButton"
					likedButton?.setBackgroundImage(UIImage(named: imageName), for: .normal)
					dateLabel?.text = post.relativeDate()
				case .history:
					profileNameLabel?.text = post.song.title
					descriptionLabel?.text = post.song.artist
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "LikedButton" : "LikeButton"
					likedButton?.setBackgroundImage(UIImage(named: imageName), for: .normal)
				}
				
				avatarImageView?.hnk_setImageFromURL(post.song.smallArtworkURL ?? URL(fileURLWithPath: ""))
				
				//! TODO: Write something that makes this nice and relative
				//! that updates every minute
				
				if User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] != nil {
					songStatus = .saved
					updateAddStatus()
				}
			}
		}
	}
	
	// Called from delegate whenever player is toggled
	override func updatePlayingStatus() {
		updateProfileLabel()
		updateBackground()
	}
	
	func updateDateLabel() {
		self.dateLabel!.isHidden = true
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				self.dateLabel!.isHidden = false
			}
		}
	}
	
	override func didMoveToWindow() {
		
		if tapGestureRecognizer == nil {
			tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postViewPressed(_:)))
			tapGestureRecognizer?.delegate = self
			tapGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(tapGestureRecognizer!)
		}
		
		if longPressGestureRecognizer == nil {
			longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postViewPressed(_:)))
			longPressGestureRecognizer?.delegate = self
			longPressGestureRecognizer?.minimumPressDuration = 0.5
			longPressGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(longPressGestureRecognizer!)
		}
		
		avatarImageView?.clipsToBounds = true
		isUserInteractionEnabled = true
		avatarImageView?.isUserInteractionEnabled = true
		profileNameLabel?.isUserInteractionEnabled = true
		
		layer.borderColor = UIColor.tempoDarkGray.cgColor
		layer.borderWidth = 0.7
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
//		if superview != nil && dateLabel != nil {
//			spacingConstraint?.constant = (dateLabel!.frame.origin.x - superview!.frame.size.width) + 8
//		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		likedButton?.tag = 1
		updateProfileLabel()
		updateBackground()
	}
	
	// Customize view to be able to re-use it for search results.
	func flagAsSearchResultPost() {
		descriptionLabel?.text = post!.song.title + " · " + post!.song.album
	}
	
	override func updateProfileLabel() {
		let avatarLayer = avatarImageView?.layer
		if let layer = avatarLayer {
			layer.transform = CATransform3DIdentity
			layer.removeAnimation(forKey: "transform.rotation")
		}
		
		if let post = post {
			let color = post.player.isPlaying ? .tempoRed : UIColor.white
			let duration = TimeInterval(0.3)
			
			guard let label = profileNameLabel else { return }
			if !label.textColor.isEqual(color) {
				UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
					label.textColor = color
				}, completion: { _ in
					label.textColor = color
				})
			}
		}
	}
	
	override func updateBackground() {
		if let post = post {
			if type == .feed {
				backgroundColor = post.player.wasPlayed ? .readCellColor : .unreadCellColor
			} else {
				backgroundColor = post.player.isPlaying ? .readCellColor : .unreadCellColor
			}
		}
	}
	
	
	func postViewPressed(_ sender: UIGestureRecognizer) {
		guard let post = post else { return }
		
		if sender is UITapGestureRecognizer {
			let tapPoint = sender.location(in: self)
			let hitView = hitTest(tapPoint, with: nil)
			let tapPointX = tapPoint.x
			if (tapPointX + 4.0) < (avatarImageView?.frame.maxX)! {
				postViewDelegate?.didTapImageForPostView?(post)
			}
			if hitView == likedButton {
				post.toggleLike()
				updateLikedStatus()
				playerDelegate.didToggleLike!()
			} else if hitView == addButton {
				PlayerCenter.sharedInstance.toggleAddButton(post: post)
				if let _ = User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] {
					songStatus = .saved
				} else {
					songStatus = .notSaved
				}
				updateAddStatus()
			}
		}
	}
	
	func updateLikedStatus() {
		if let post = post {
			let name = post.isLiked ? "LikedButton" : "LikeButton"
			likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
			likedButton?.setBackgroundImage(UIImage(named: name), for: .normal)
		}
	}
	
	func updateAddStatus() {
		if let post = post {
			if let currentPost = PlayerCenter.sharedInstance.getCurrentPost(), currentPost.equals(other: post) {
				songStatus = PlayerCenter.sharedInstance.getSongStatus()
			}
			let image = songStatus == .saved ? #imageLiteral(resourceName: "AddedButton") : #imageLiteral(resourceName: "AddButton")
			addButton?.setBackgroundImage(image, for: .normal)
		}
	}
}

