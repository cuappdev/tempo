//
//  ExpandedPlayerView.swift
//  Tempo
//
//  Created by Logan Allen on 10/26/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

class ExpandedPlayerView: UIView, UIGestureRecognizerDelegate {
	
	private let height = CGFloat(198)
	
	@IBOutlet weak var postDetailLabel: UILabel!
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
	@IBOutlet weak var albumImage: UIImageView!
	@IBOutlet weak var topViewContainer: UIView!
	
	@IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var progressView: ProgressView!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var likeButtonImage: UIImageView!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var collapseButton: UIButton!
	@IBOutlet weak var addButtonImage: UIImageView!
	
	var progressIndicator: UIView!
	
	var postsLikable: Bool? {
		didSet {
			likeButton.hidden = !(postsLikable!)
		}
	}
	var postHasInfo = false
	var parentNav: PlayerNavigationController?
	
	var songStatus: SavedSongStatus = .NotSaved
	var post: Post?
	var delegate: PlayerDelegate!
	private var wasPlaying = false
	
	var tapGestureRecognizer: UITapGestureRecognizer?
	var panGestureRecognizer: UIPanGestureRecognizer?
	var initialPanView: UIView?
	
	func setup(parent: PlayerNavigationController) {
		backgroundColor = .tempoSuperDarkGray
		// Setup gesture recognizers
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.expandedCellTapped(_:)))
		tapGestureRecognizer?.delegate = self
		tapGestureRecognizer?.cancelsTouchesInView = false
		addGestureRecognizer(tapGestureRecognizer!)
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.progressPanned(_:)))
		panGestureRecognizer?.delegate = self
		panGestureRecognizer?.delaysTouchesBegan = false
		addGestureRecognizer(panGestureRecognizer!)
		
		let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.collapseTap(_:)))
		closeTapGestureRecognizer.cancelsTouchesInView = false
		topViewContainer.addGestureRecognizer(closeTapGestureRecognizer)
		let cellPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.collapsePan(_:)))
		cellPanGestureRecognizer.delaysTouchesBegan = false
		topViewContainer.addGestureRecognizer(cellPanGestureRecognizer)
		
		parentNav = parent
		progressView.playerDelegate = parentNav
		progressView.backgroundColor = .tempoSuperDarkRed
		
		progressIndicator = UIView(frame: CGRectMake(progressView.frame.origin.x - 6, progressView.frame.origin.y - 6, 12, 12))
		progressIndicator.layer.cornerRadius = 6
		progressIndicator.backgroundColor = .tempoLightRed
		progressIndicator.userInteractionEnabled = true
		addSubview(progressIndicator)
		bringSubviewToFront(playToggleButton)
		
		progressView.indicator = progressIndicator
		
		playToggleButton.layer.cornerRadius = 5
		playToggleButton.clipsToBounds = true
		
		updateAddButton()
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
	}
	
	func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		albumImage.hnk_setImageFromURL(newPost.song.smallArtworkURL ?? NSURL())
		postDetailLabel.text = postHasInfo ? "\(newPost.user.name) posted \(getPostTime(newPost.relativeDate())) ago" : ""
		songLabel.holdScrolling = false
		artistLabel.holdScrolling = false
		
		updateAddButton()
		updateLikeButton()
		updateSongStatus()
		updatePlayingStatus()
	}
	
	private func getPostTime(time: String) -> String {
		let num: String = time.substringToIndex(time.endIndex.advancedBy(-1))
		let unit: String = time.substringFromIndex(time.endIndex.advancedBy(-1))
		let convertedUnit: String = {
			switch unit {
				case "s":
					return (Int(num) == 1) ? "second" : "seconds"
				case "m":
					return (Int(num) == 1) ? "minute" : "minutes"
				case "h":
					return (Int(num) == 1) ? "hour" : "hours"
				case "d":
					return (Int(num) == 1) ? "day" : "days"
				default:
					return (Int(num) == 1) ? "decade" : "decades"
			}
		}()
		return "\(num) \(convertedUnit)"
	}
	
	private func updateSongStatus() {
		if let selectedPost = post {
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) ?? false {
				songStatus = .Saved
			} else {
				songStatus = .NotSaved
			}
		}
	}
	
	func updatePlayingStatus() {
		if let selectedPost = post {
			let isPlaying = selectedPost.player.isPlaying
			songLabel.holdScrolling = !isPlaying
			artistLabel.holdScrolling = !isPlaying
		}
		
		updatePlayToggleButton()
	}
	
	func collapseTap(sender: UITapGestureRecognizer) {
		// Collapse expanded cell
		parentNav?.animateExpandedCell(false)
	}
	
	func expandedCellTapped(sender: UITapGestureRecognizer) {
		let tapPoint = sender.locationInView(self)
		let hitView = hitTest(tapPoint, withEvent: nil)
		
		if hitView == playToggleButton {
			if let _ = post {
				delegate.didTogglePlaying(true)
			}
		} else if hitView == addButton {
			if songStatus == .NotSaved {
				SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
					if success {
						self.addButtonImage.image = UIImage(named: "check")
						self.songStatus = .Saved
					}
				}
			} else if songStatus == .Saved {
				SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
					if success {
						self.addButtonImage.image = UIImage(named: "plus")
						self.songStatus = .NotSaved
					}
				}
			}
		} else if hitView == likeButton {
			if let post = post where postsLikable! ?? false {
				post.toggleLike()
				delegate.didToggleLike!()
			}
		}
	}
	
	dynamic func progressPanned(gesture: UIPanGestureRecognizer) {
		if gesture.state != .Ended {
			if post?.player.isPlaying ?? false {
				delegate.didTogglePlaying(false)
				wasPlaying = true
			}
		} else {
			if wasPlaying {
				delegate.didTogglePlaying(false)
			}
			wasPlaying = false
			initialPanView = nil
		}
		
		let panPoint = gesture.locationInView(self)
		let xTranslation = panPoint.x
		let progressWidth = progressView.bounds.width
		
		let progress = Double((xTranslation - progressView.frame.origin.x)/progressWidth)
		post?.player.progress = progress
		delegate.didChangeProgress!()
		
		progressView.setNeedsDisplay()
	}
	
	func collapsePan(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translationInView(self)
		if gesture.state == .Began || gesture.state == .Changed {
			let maxCenter = UIScreen.mainScreen().bounds.height - height/2.0
			
			if translation.y > 0 || center.y > maxCenter {
				center.y = center.y + translation.y < maxCenter ? maxCenter : center.y + translation.y
			}
			gesture.setTranslation(CGPointZero, inView: self)
		}
		
		if gesture.state == .Ended {
			let velocity = gesture.velocityInView(self)
			parentNav?.animateExpandedCell(velocity.y < 0)
			initialPanView = nil
		}
		setNeedsDisplay()
	}
	
	func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause-red" : "play-red"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), forState: .Normal)
		}
	}
	
	private func updateAddButton() {
		addButton.userInteractionEnabled = false
		addButton.hidden = true
		if let _ = post {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success {
					self.addButton.hidden = false
					self.addButton.userInteractionEnabled = true
					self.addButtonImage.image = (self.songStatus == .Saved) ? UIImage(named: "check") : UIImage(named: "plus")
				}
			}
		}
	}
	
	func updateLikeButton() {
		if let selectedPost = post {
			if postsLikable! ?? false {
				let name = selectedPost.isLiked ? "filled-heart" : "empty-heart"
				likeButtonImage.image = UIImage(named: name)
			}
		}
	}
	
	private func setupMarqueeLabel(label: MarqueeLabel) {
		label.speed = .Duration(8)
		label.trailingBuffer = 10
		label.type = .Continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
	func resetPlayerCell() {
		post = nil
		songLabel.text = ""
		artistLabel.text = ""
		albumImage.hnk_setImageFromURL(NSURL())
		postDetailLabel.text = ""
	}
}
