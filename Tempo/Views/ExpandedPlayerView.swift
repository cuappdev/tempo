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
	@IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var progressView: ProgressView!
	@IBOutlet weak var progressIndicator: UIView!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonImage: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collapseButton: UIButton!
	
    @IBOutlet weak var addButtonImage: UIImageView!
	var postsLikable = false
	var postHasInfo = false
	var parentNav: PlayerNavigationController?
	
	var songStatus: SavedSongStatus = .NotSaved
	var post: Post?
	private var wasPlaying = false
	
	private var tapGestureRecognizer: UITapGestureRecognizer?
	private var panGestureRecognizer: UIPanGestureRecognizer?
	var initialPanView: UIView?
	
	func setup(parent: PlayerNavigationController) {
		// Setup gesture recognizers
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.expandedCellTapped(_:)))
		tapGestureRecognizer?.delegate = self
		tapGestureRecognizer?.cancelsTouchesInView = false
		addGestureRecognizer(tapGestureRecognizer!)
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.expandCellPanned(_:)))
		panGestureRecognizer?.delegate = self
		panGestureRecognizer?.delaysTouchesBegan = false
		addGestureRecognizer(panGestureRecognizer!)
		
		// setup cell
		parentNav = parent
		progressView.playerDelegate = parentNav
		progressView.backgroundColor = UIColor.tempoSuperDarkRed
		progressView.indicator = progressIndicator
		progressIndicator.backgroundColor = UIColor.clearColor()
		progressIndicator.userInteractionEnabled = true
		let indicator = progressIndicator.subviews.first!
		indicator.backgroundColor = UIColor.tempoLightRed
		indicator.layer.cornerRadius = 6
		indicator.center.x = progressView.frame.origin.x
		
		playToggleButton.layer.cornerRadius = 5
		playToggleButton.clipsToBounds = true
		
		updateAddButton()
		likeButton.userInteractionEnabled = false
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
	}
	
	func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		albumImage.hnk_setImageFromURL(newPost.song.smallArtworkURL ?? NSURL())
		if postHasInfo {
			let time = getPostTime(newPost.relativeDate())
			postDetailLabel.text = "\(newPost.user.name) posted \(time) ago"
		} else {
			postDetailLabel.text = ""
		}
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
	
	func expandedCellTapped(sender: UITapGestureRecognizer) {
		let tapPoint = sender.locationInView(self)
		let hitView = hitTest(tapPoint, withEvent: nil)
		
		if hitView == playToggleButton {
			if let selectedPost = post {
				selectedPost.player.togglePlaying()
				updatePlayToggleButton()
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
			if let selectedPost = post {
				selectedPost.toggleLike()
				updateLikeButton()
				NSNotificationCenter.defaultCenter().postNotificationName(PostLikedStatusChangeNotification, object: self)
			}
		} else {
			// Collapse expanded cell
			parentNav?.animateExpandedCell(false)
		}
	}
	
	dynamic func expandCellPanned(gesture: UIPanGestureRecognizer) {
		let panPoint = gesture.locationInView(self)
		var panView = hitTest(panPoint, withEvent: nil)
		if let pv = initialPanView {
			panView = pv
		} else {
			initialPanView = panView
		}
		
		if panView == progressIndicator {
			print("progress...")
			if gesture.state != .Ended {
				if post?.player.isPlaying ?? false {
					post?.player.pause(false)
					wasPlaying = true
				}
			} else {
				if wasPlaying {
					post?.player.play(false)
				}
				wasPlaying = false
				initialPanView = nil
			}
			
			let xTranslation = panPoint.x
			let progressWidth = progressView.bounds.width
			
			let progress = Double((xTranslation - progressView.frame.origin.x)/progressWidth)
			post?.player.progress = progress
			
			progressView.setNeedsDisplay()
		} else {
			print("...Panning")
			if panView == progressView {
				initialPanView = nil
				return
			}
			let translation = gesture.translationInView(self)
			if gesture.state == .Began || gesture.state == .Changed {
				let maxCenter = UIScreen.mainScreen().bounds.height - height/2
				
				if translation.y > 0 || gesture.view!.center.y > maxCenter {
					if gesture.view!.center.y + translation.y < maxCenter {
						gesture.view!.center.y = maxCenter
					} else {
						gesture.view!.center.y = gesture.view!.center.y + translation.y
					}
				}
				gesture.setTranslation(CGPointMake(0,0), inView: self)
			}
			
			if gesture.state == .Ended {
				let velocity = gesture.velocityInView(self)
				parentNav?.animateExpandedCell(velocity.y < 0)
				initialPanView = nil
			}
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
			if postsLikable {
				likeButton.userInteractionEnabled = true
				let name = selectedPost.isLiked ? "filled-heart" : "empty-heart"
				likeButtonImage.image = UIImage(named: name)
			} else {
				likeButton.userInteractionEnabled = false
				likeButtonImage.image = UIImage(named: "empty-heart")
			}
		}
	}
	
//	@IBAction func playToggleButtonClicked(sender: UIButton) {
//		if let selectedPost = post {
//			selectedPost.player.togglePlaying()
//			updatePlayToggleButton()
//		}
//	}
	
//	@IBAction func addButtonClicked(sender: UIButton) {
//		if songStatus == .NotSaved {
//			SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
//				if success {
//					self.addButtonImage.image = UIImage(named: "check")
//					self.songStatus = .Saved
//				}
//			}
//		} else if songStatus == .Saved {
//			SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
//				if success {
//					self.addButtonImage.image = UIImage(named: "plus")
//					self.songStatus = .NotSaved
//				}
//			}
//		}
//	}
	
	
//	@IBAction func likeButtonClicked(sender: UIButton) {
//		if let selectedPost = post {
//			selectedPost.toggleLike()
//			updateLikeButton()
//			NSNotificationCenter.defaultCenter().postNotificationName(PostLikedStatusChangeNotification, object: self)
//		}
//	}
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		print("drawing...")
		progressIndicator.center.x = progressView.frame.origin.x + progressView.bounds.width + CGFloat(parentNav?.currentPost?.player.progress ?? 0)
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
	
}
