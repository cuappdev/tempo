//
//  PlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

class PlayerCellView: UIView {
	
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
	
	var postsLikable: Bool? {
		didSet {
			likeButton.isHidden = !(postsLikable!)
		}
	}
	var parentNav: PlayerNavigationController?
	
	var songStatus: SavedSongStatus = .notSaved
	var post: Post?
	var delegate: PlayerDelegate!
	
	func setup(parent: PlayerNavigationController) {
		parentNav = parent
		backgroundColor = UIColor.tempoSuperDarkGray
		let tap = UITapGestureRecognizer(target: self, action: #selector(expandTap(sender:)))
		addGestureRecognizer(tap)
		progressView.playerDelegate = parentNav
		progressView.backgroundColor = UIColor.tempoSuperDarkRed
		
		updateAddButton()

		playToggleButton.layer.cornerRadius = 5
		playToggleButton.clipsToBounds = true
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
	}
	
	func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		songLabel.holdScrolling = false
		artistLabel.holdScrolling = false
		isUserInteractionEnabled = true
		
		updateAddButton()
		updateLikeButton()
		updateSongStatus()
		updatePlayingStatus()
	}
	
	fileprivate func updateSongStatus() {
		if let selectedPost = post {
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	func expandTap(sender: UITapGestureRecognizer) {
		parentNav?.animateExpandedCell(isExpanding: true)

	}
	
	func updatePlayingStatus() {
		if let selectedPost = post {
			let isPlaying = selectedPost.player.isPlaying
			songLabel.holdScrolling = !isPlaying
			artistLabel.holdScrolling = !isPlaying
		}
		
		updatePlayToggleButton()
	}
	
    @IBAction func playToggleButtonClicked(sender: UIButton) {
        if let _ = post {
            delegate.didTogglePlaying(animate: true)
        }
    }
	
	func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause-red" : "play-red"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), for: UIControlState())
		}
	}
    
	@IBAction func addButtonClicked(_ sender: UIButton) {
		if songStatus == .notSaved {
			SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
				if success {
					self.addButton.setBackgroundImage(UIImage(named: "check"), for: .normal)
					self.songStatus = .saved
				}
			}
		} else if songStatus == .saved {
			SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
				if success {
					self.addButton.setBackgroundImage(UIImage(named: "plus"), for: .normal)
					self.songStatus = .notSaved
				}
			}
		}
	}
	
	private func updateAddButton() {
		addButton!.isHidden = true
		if let _ = post {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success {
					self.addButton!.isHidden = false

				}
			}
		}
	}
	
	@IBAction func likeButtonClicked(sender: UIButton) {
		if let selectedPost = post, (postsLikable ?? false) {
			selectedPost.toggleLike()
			updateLikeButton()
			delegate.didToggleLike!()
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
	
	fileprivate func setupMarqueeLabel(_ label: MarqueeLabel) {
		label.speed = .duration(8)
		label.trailingBuffer = 10
		label.type = .continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
	func resetPlayerCell() {
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

