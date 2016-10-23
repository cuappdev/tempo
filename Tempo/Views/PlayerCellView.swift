//
//  PlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

let PostLikedStatusChangeNotification = "PostLikedStatusChange"

protocol PostDelegate {
	var post: Post? { get }
}

class PlayerCellView: UIView, PostDelegate {
	
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
	
	var postsRef: [Post]?
	var postRefIndex: Int?
	
	var post: Post? {
		didSet {
			if let newPost = post {
				artistLabel.text = newPost.song.artist
				songLabel.text = newPost.song.title
				
				updateAddButton()
				updateLikeButton()
				updateSongStatus()
				updatePlayingStatus()
				
				progressView.setUpTimer()
				songLabel.holdScrolling = false
				artistLabel.holdScrolling = false
			}
		}
	}
	
	var songStatus: SavedSongStatus = .NotSaved
	
	func setup() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerCellView.expandTap(_:)))
		self.addGestureRecognizer(tap)
		progressView.delegate = self
		
		updateAddButton()
		likeButton.userInteractionEnabled = false
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] note in
			if let current = self?.post {
				if current.player == note.object as? Player {
					if let path = self?.postRefIndex {
						var index = path + 1
						if let postsRef = self?.postsRef {
							let count = postsRef.count
							index = index >= count ? 0 : index
							self?.post = postsRef[index]
							self?.postRefIndex = index
							self?.playToggleButtonClicked((self?.playToggleButton)!)
							self?.progressView.setUpTimer() //manually reset timer
						}
					}
				}
			}
		}
	}
	
	private func updateSongStatus() {
		if let selectedPost = post {
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) ?? false {
				songStatus = .Saved
			}
		}
	}
	
	func expandTap(sender: UITapGestureRecognizer) {
        print("EXPANDING")
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
        if let selectedPost = post {
            selectedPost.player.togglePlaying()
			updatePlayToggleButton()
        }
    }
	
	private func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause" : "play"
			playToggleButton.setBackgroundImage(UIImage(named: name), forState: .Normal)
		}
	}
    
	@IBAction func addButtonClicked(sender: UIButton) {
		if songStatus == .NotSaved {
			SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
				if success {
					self.addButton?.setImage(UIImage(named: "check"), forState: .Normal)
					self.songStatus = .Saved
				}
			}
		} else if songStatus == .Saved {
			SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
				if success {
					self.addButton?.setImage(UIImage(named: "plus"), forState: .Normal)
					self.songStatus = .NotSaved
				}
			}
		}
	}
	
	private func updateAddButton() {
		addButton!.hidden = true
		if let _ = post {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success {
					self.addButton!.userInteractionEnabled = false
				}
			}
		}
	}
	
	@IBAction func likeButtonClicked(sender: UIButton) {
		if let selectedPost = post {
			selectedPost.toggleLike()
			updateLikeButton()
			NSNotificationCenter.defaultCenter().postNotificationName(PostLikedStatusChangeNotification, object: self)
		}
	}
	
	private func updateLikeButton() {
		if let selectedPost = post {
			likeButton.userInteractionEnabled = true
			let name = selectedPost.isLiked ? "filled-heart" : "empty-heart"
			likeButton?.setBackgroundImage(UIImage(named: name), forState: .Normal)
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
}