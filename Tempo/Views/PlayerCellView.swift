//
//  PlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

class PlayerCellView: ParentPlayerCellView {

	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
	
	func setup(parent: PlayerNavigationController) {
		playerNav = parent
		backgroundColor = .tempoOffBlack
		
		let tap = UILongPressGestureRecognizer(target: self, action: #selector(playerCellTapped(sender:)))
		tap.minimumPressDuration = 0
		addGestureRecognizer(tap)
		
		progressView.playerDelegate = playerNav
		progressView.backgroundColor = .tempoDarkRed

		playToggleButton.isUserInteractionEnabled = false
		addButton.isUserInteractionEnabled = false
		likeButton.isUserInteractionEnabled = false
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
	}
	
	override func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		
		songLabel.holdScrolling = false
		artistLabel.holdScrolling = false
		isUserInteractionEnabled = true
		
		updateLikeButton()
		updateSavedStatus()
		updatePlayingStatus()
		updateAddButton()
	}
	
	override internal func updateSavedStatus() {
		if let selectedPost = post {
			if let _ = User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	func playerCellTapped(sender: UILongPressGestureRecognizer) {
		let tapPoint = sender.location(in: self)
		let separatorPoint = (addButton.frame.right.x + likeButton.frame.left.x) / 2
		
		if sender.state == .began {
			if (tapPoint.x > playToggleButton.frame.right.x + 12 && tapPoint.x < addButton.frame.left.x - 12) {
				playerNav?.animateExpandedCell(isExpanding: true)
			}
		} else if sender.state == .ended {
			if (tapPoint.x < playToggleButton.frame.right.x + 12) {
				playToggleButtonClicked()
			} else if (tapPoint.x > addButton.frame.left.x - 12 && tapPoint.x < separatorPoint) {
				addButtonClicked()
			} else if (tapPoint.x > separatorPoint) {
				likeButtonClicked()
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
	
    func playToggleButtonClicked() {
        if let _ = post {
            delegate?.didTogglePlaying(animate: true)
        }
    }
	
	override func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "PauseButton" : "PlayButton"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), for: .normal)
		}
	}
    
	func addButtonClicked() {
		if let _ = post {
			toggleAddButton()
		}
	}
	
	func likeButtonClicked() {
		if let selectedPost = post, (postsLikable ?? false) {
			selectedPost.toggleLike()
			updateLikeButton()
			delegate?.didToggleLike?()
		}
	}
	
	func updateLikeButton() {
		if let selectedPost = post {
			let name = (selectedPost.isLiked || playerNav.playingPostType == .liked) ? "LikedButton" : "LikeButton"
			likeButton?.setBackgroundImage(UIImage(named: name), for: .normal)
		}
	}
	
	override func updateAddButton() {
		updateSavedStatus()
		let image = (songStatus == .saved) ? #imageLiteral(resourceName: "AddedButton") : #imageLiteral(resourceName: "AddButton")
		addButton.setBackgroundImage(image, for: .normal)
	}
	
	fileprivate func setupMarqueeLabel(_ label: MarqueeLabel) {
		label.speed = .duration(8)
		label.trailingBuffer = 10
		label.type = .continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
	override func resetPlayerCell() {
		if let delegate = delegate, post != nil {
			if post!.player.isPlaying {
				delegate.didTogglePlaying(animate: false)
			}
		}
		super.resetPlayerCell()
		songLabel.text = ""
		artistLabel.text = ""
		progressView.setNeedsDisplay()
	}
}

