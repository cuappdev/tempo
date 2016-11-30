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
	
	override var postsLikable: Bool? {
		didSet {
			likeButton.isUserInteractionEnabled = postsLikable!
		}
	}
	
	func setup(parent: PlayerNavigationController) {
		playerNav = parent
		backgroundColor = UIColor.tempoSuperDarkGray
		let tap = UITapGestureRecognizer(target: self, action: #selector(expandTap(sender:)))
		addGestureRecognizer(tap)
		progressView.playerDelegate = playerNav
		progressView.backgroundColor = UIColor.tempoSuperDarkRed

		playToggleButton.layer.cornerRadius = 5
		playToggleButton.clipsToBounds = true
		
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
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	func expandTap(sender: UITapGestureRecognizer) {
		playerNav?.animateExpandedCell(isExpanding: true)
	}
	
	override func updatePlayingStatus() {
		if let selectedPost = post {
			let isPlaying = selectedPost.player.isPlaying
			songLabel.holdScrolling = !isPlaying
			artistLabel.holdScrolling = !isPlaying
		}
		
		updatePlayToggleButton()
	}
	
    @IBAction func playToggleButtonClicked(sender: UIButton) {
        if let _ = post {
            delegate?.didTogglePlaying(animate: true)
        }
    }
	
	override func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause" : "play"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), for: UIControlState())
		}
	}
    
	@IBAction func addButtonClicked(_ sender: UIButton) {
		if let _ = post {
			toggleAddButton()
		}
	}
	
	@IBAction func likeButtonClicked(sender: UIButton) {
		if let selectedPost = post, (postsLikable ?? false) {
			selectedPost.toggleLike()
			updateLikeButton()
			delegate?.didToggleLike?()
		}
	}
	
	func updateLikeButton() {
		if let selectedPost = post {
			if postsLikable! {
				let name = selectedPost.isLiked ? "filled-heart" : "empty-heart"
				likeButton?.setBackgroundImage(UIImage(named: name), for: .normal)
			}
		}
	}
	
	override func updateAddButton() {
		updateSavedStatus()
		let image = songStatus == .saved ? UIImage(named: "check") : UIImage(named: "plus")
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
		post = nil
		songLabel.text = ""
		artistLabel.text = ""
	}
}

