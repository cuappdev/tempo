//
//  ExpandedPlayerView.swift
//  Tempo
//
//  Created by Logan Allen on 10/26/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

class ExpandedPlayerView: ParentPlayerCellView, UIGestureRecognizerDelegate {
	
	let progressIndicatorLength: CGFloat = 12
	
	@IBOutlet weak var postDetailLabel: UILabel!
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
	@IBOutlet weak var albumImage: UIImageView!
	@IBOutlet weak var topViewContainer: UIView!
	
	@IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var progressView: ProgressView!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var likeButtonImage: UIImageView!
    @IBOutlet weak var likeButtonLabel: UILabel!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var addButtonImage: UIImageView!
	@IBOutlet weak var addButtonLabel: UILabel!
	@IBOutlet weak var openButton: UIButton!
	@IBOutlet weak var bottomButtonsView: UIView!
	@IBOutlet weak var collapseButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var prevButton: UIButton!
	
	var progressIndicator: UIView!
	
	override var postsLikable: Bool? {
		didSet {
			likeButton.isUserInteractionEnabled = postsLikable!
		}
	}

	private var wasPlaying = false
	
	var tapGestureRecognizer: UITapGestureRecognizer?
	var panGestureRecognizer: UIPanGestureRecognizer?
	var initialPanView: UIView?
	
	func setup(parent: PlayerCenter) {
		backgroundColor = .tempoOffBlack
		bottomButtonsView.backgroundColor = .clear
		
		// Setup gesture recognizers
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandedCellTapped(sender:)))
		tapGestureRecognizer?.delegate = self
		tapGestureRecognizer?.cancelsTouchesInView = false
		addGestureRecognizer(tapGestureRecognizer!)
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(progressPanned(gesture:)))
		panGestureRecognizer?.delegate = self
		panGestureRecognizer?.delaysTouchesBegan = false
		bottomButtonsView.addGestureRecognizer(panGestureRecognizer!)
		
//		let cellPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(collapsePan(gesture:)))
//		cellPanGestureRecognizer.delaysTouchesBegan = false
//		topViewContainer.addGestureRecognizer(cellPanGestureRecognizer)
		
		playerCenter = parent
		progressView.playerDelegate = playerCenter
		progressView.backgroundColor = .tempoDarkRed
		
		progressIndicator = UIView(frame: CGRect(x: progressView.frame.origin.x - 5, y: progressView.frame.origin.y - 5, width: progressIndicatorLength, height: progressIndicatorLength))
		progressIndicator.layer.cornerRadius = progressIndicator.frame.height/2
		progressIndicator.clipsToBounds = true
		progressIndicator.backgroundColor = .tempoRed
		progressIndicator.isUserInteractionEnabled = true
		bringSubview(toFront: playToggleButton)
		
		progressView.indicator = progressIndicator
		progressView.addSubview(progressIndicator)

		setupMarqueeLabel(label: songLabel)
		setupMarqueeLabel(label: artistLabel)
		
		if (iPhone5){
			addButtonLabel.text = (songStatus == .saved) ? "Saved" : "Save"
			let leadingContraints = NSLayoutConstraint(item: addButton, attribute:
				.leadingMargin, relatedBy: .equal, toItem: likeButton,
				                 attribute: .leadingMargin, multiplier: 1.0, constant: 72)
			let trailingConstraints = NSLayoutConstraint(item: addButton, attribute:
				.trailingMargin, relatedBy: .equal, toItem: openButton,
				                attribute: .leadingMargin, multiplier: 1.0, constant: -30)
			let widthContraints = NSLayoutConstraint(item: addButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 60)
			NSLayoutConstraint.activate([leadingContraints, trailingConstraints, widthContraints])
		} else {
			addButtonLabel.text = (songStatus == .saved) ? "Saved to Spotify" : "Save to Spotify"
		}
	}
	
	override func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		albumImage.hnk_setImageFromURL(newPost.song.largeArtworkURL ?? NSURL() as URL)
		
		if delegate is FeedViewController {
			postDetailLabel.text = "\(newPost.user.firstName) \(newPost.user.shortenLastName()) posted \(getPostTime(time: newPost.relativeDate())) ago"
		} else if delegate is LikedTableViewController {
			postDetailLabel.text = "Playing from your Liked Songs"
		} else if delegate is PostHistoryTableViewController {
			postDetailLabel.text = "Playing from your Post History"
		} else if delegate is SearchViewController {
			postDetailLabel.text = "Playing from your Search Results"
		}
		
		songLabel.holdScrolling = false
		artistLabel.holdScrolling = false
		
		updateLikeButton()
		updateSavedStatus()
		updatePlayingStatus()
		updateAddButton()
	}
	
	private func getPostTime(time: String) -> String {
		let num: String = time.substring(to: time.index(before: time.endIndex))
		let unit: String = time.substring(from: time.index(before: time.endIndex))
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
	
	override internal func updateSavedStatus() {
		if let selectedPost = post {
			if User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	override func updatePlayingStatus() {
		if let selectedPost = post {
			let isPlaying = selectedPost.player.isPlaying
			songLabel.holdScrolling = !isPlaying
			artistLabel.holdScrolling = !isPlaying
		}
		
		updatePlayToggleButton()
	}
	
	func expandedCellTapped(sender: UITapGestureRecognizer) {
		let tapPoint = sender.location(in: self)
		let hitView = hitTest(tapPoint, with: nil)
		
		if hitView == playToggleButton {
			if let _ = post {
				delegate?.didTogglePlaying(animate: true)
			}
		} else if hitView == addButton {
			if let _ = post {
				toggleAddButton()
			}
		} else if hitView == likeButton {
			if let post = post, postsLikable! {
				post.toggleLike()
				delegate?.didToggleLike!()
			}
		} else if let post = post, hitView == openButton {
			
			guard let appURL = URL(string: "spotify://track/\(post.song.spotifyID)"),
			let webURL = URL(string: "https://open.spotify.com/track/\(post.song.spotifyID)") else { return }
			
			if UIApplication.shared.canOpenURL(appURL) {
				UIApplication.shared.openURL(appURL)
			} else {
				UIApplication.shared.openURL(webURL)
			}
			
		} else if hitView == nextButton {
			delegate?.playNextSong?()
		} else if hitView == prevButton {
			delegate?.playPrevSong?()
		} else {
			playerCenter.collapseAccessoryViewController(animated: true)
		}
	}
	
	dynamic func progressPanned(gesture: UIPanGestureRecognizer) {
		if gesture.state != .ended {
			if post?.player.isPlaying ?? false {
				delegate?.didTogglePlaying(animate: false)
				wasPlaying = true
			}
		} else {
			if wasPlaying {
				delegate?.didTogglePlaying(animate: false)
			}
			wasPlaying = false
			initialPanView = nil
		}
		
		let panPoint = gesture.location(in: self)
		let xTranslation = panPoint.x
		let progressWidth = progressView.bounds.width
		
		let progress = Double((xTranslation - progressView.frame.origin.x)/progressWidth)
		post?.player.progress = progress
		delegate?.didChangeProgress?()
		
		progressView.setNeedsDisplay()
	}
	
//	func collapsePan(gesture: UIPanGestureRecognizer) {
//		let translation = gesture.translation(in: self)
//		if gesture.state == .began || gesture.state == .changed {
//			let maxCenter = UIScreen.main.bounds.height - expandedPlayerHeight/2.0
//			
//			if translation.y > 0 || center.y > maxCenter {
//				center.y = center.y + translation.y < maxCenter ? maxCenter : center.y + translation.y
//			}
//			gesture.setTranslation(CGPoint.zero, in: self)
//		}
//		
//		if gesture.state == .ended {
//			let velocity = gesture.velocity(in: self)
//			playerCenter.animateExpandedCell(isExpanding: velocity.y < 0)
//			initialPanView = nil
//		}
//		setNeedsDisplay()
//	}
	
	override func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "PlayerPauseButton" : "PlayerPlayButton"
			progressView.setUpTimer()
			playToggleButton.setImage(UIImage(named: name), for: .normal)
		}
	}
	
	func updateLikeButton() {
		if let selectedPost = post {
			let name = (selectedPost.isLiked || selectedPost.postType == .liked) ? "LikedButton" : "PlayerLikeButton"
			likeButtonImage.image = UIImage(named: name)
			likeButtonLabel.text = (selectedPost.isLiked || selectedPost.postType == .liked)  ? "Liked" : "Like"
		}
	}
	
	override func updateAddButton() {
		updateSavedStatus()
		addButtonImage.image = (songStatus == .saved) ? #imageLiteral(resourceName: "ExpandedPlayerAddedButton") : #imageLiteral(resourceName: "ExpandedPlayerAddButton")
		
		if (iPhone5){
			addButtonLabel.text = (songStatus == .saved) ? "Saved" : "Save"
		} else {
			addButtonLabel.text = (songStatus == .saved) ? "Saved to Spotify" : "Save to Spotify"
		}
	}
	
	private func setupMarqueeLabel(label: MarqueeLabel) {
		label.speed = .duration(8)
		label.trailingBuffer = 10
		label.type = .continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
	override func resetPlayerCell() {
		super.resetPlayerCell()
		songLabel.text = ""
		artistLabel.text = ""
		albumImage.hnk_setImageFromURL(NSURL() as URL)
		postDetailLabel.text = ""
		progressView.setNeedsDisplay()
	}
}
