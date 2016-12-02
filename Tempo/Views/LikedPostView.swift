//
//  LikedPostView.swift
//  Tempo
//
//  Created by Logan Allen on 11/18/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MediaPlayer
import Haneke

class LikedPostView: UIView, UIGestureRecognizerDelegate {
	fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
	fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
	
	let artworkImageLength: CGFloat = 45
	let addButtonLength: CGFloat = 20
	
	var songNameLabel: UILabel?
	var songArtistLabel: UILabel?
	var albumArtworkImageView: UIImageView?
	var addButton: UIButton?

	var songStatus: SavedSongStatus = .notSaved
	var postViewDelegate: PostViewDelegate!
	var playerDelegate: PlayerDelegate!
	
	var playerController: PlayerTableViewController?
	
	var post: Post? {
		didSet {
			// update stuff
			if let post = post {
				songNameLabel?.text = post.song.title
				songArtistLabel?.text = post.song.artist
				
				albumArtworkImageView?.hnk_setImageFromURL(post.song.smallArtworkURL ?? URL(fileURLWithPath: ""))
				
				if User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] != nil {
					songStatus = .saved
				}
				
				updateAddButton()
			}
		}
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		backgroundColor = .unreadCellColor
		
		albumArtworkImageView = UIImageView(frame: CGRect(x: 22, y: 22, width: artworkImageLength, height: artworkImageLength))
		albumArtworkImageView?.center.y = center.y
		albumArtworkImageView?.clipsToBounds = true
		albumArtworkImageView?.translatesAutoresizingMaskIntoConstraints = true
		addSubview(albumArtworkImageView!)

		let labelX = (albumArtworkImageView?.frame.maxX)! + 25
		let labelWidth = bounds.width - labelX - 64
		songNameLabel = UILabel(frame: CGRect(x: labelX, y: 22, width: labelWidth, height: 22))
		songNameLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		songNameLabel?.textColor = .white
		songNameLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songNameLabel!)
		
		songArtistLabel = UILabel(frame: CGRect(x: labelX, y: (songNameLabel?.frame.maxY)!, width: labelWidth, height: 22))
		songArtistLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		songArtistLabel?.textColor = .paleRed
		songArtistLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songArtistLabel!)
		
		addButton = UIButton(frame: CGRect(x: frame.width - addButtonLength - 17, y: 34, width: addButtonLength, height: addButtonLength))
		addButton?.center.y = center.y
		addButton?.setBackgroundImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
		addButton?.translatesAutoresizingMaskIntoConstraints = true
		addButton?.tag = 1 // this tag makes the hitbox bigger
		addSubview(addButton!)
	}
	
	func updatePlayingStatus() {
		updateSongLabel()
		updateBackground()
	}
	
	override func didMoveToWindow() {
		if tapGestureRecognizer == nil {
			tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likedPostViewPressed(_:)))
			tapGestureRecognizer?.delegate = self
			tapGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(tapGestureRecognizer!)
		}
		
		if longPressGestureRecognizer == nil {
			longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(likedPostViewPressed(_:)))
			longPressGestureRecognizer?.delegate = self
			longPressGestureRecognizer?.minimumPressDuration = 0.5
			longPressGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(longPressGestureRecognizer!)
		}
		
		isUserInteractionEnabled = true
	}
	
	// Customize view to be able to re-use it for search results.
	func flagAsSearchResultPost() {
		songArtistLabel?.text = "\(post!.song.title) · \(post!.song.album)"
	}
	
	func updateAddButton() {
		addButton!.isHidden = true
		if let _ = post {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success {
					self.addButton!.isHidden = false
				}
			}
			if songStatus == .saved {
				self.addButton?.setBackgroundImage(UIImage(named: "check"), for: .normal)
			} else {
				self.addButton?.setBackgroundImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
			}
		}
	}
	
	func updateSongLabel() {
		if let post = post {
			let duration = TimeInterval(0.3)
			let color: UIColor = post.player.isPlaying ? .tempoRed : .white
			let font: UIFont = post.player.isPlaying ? UIFont(name: "AvenirNext-Medium", size: 16.0)! : UIFont(name: "AvenirNext-Regular", size: 16.0)!
			
			guard let label = songNameLabel else { return }
			if !label.textColor.isEqual(color) {
				UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
					label.textColor = color
					label.font = font
				})
			}
		}
	}
	
	func updateBackground() {
		if let post = post {
			backgroundColor = post.player.isPlaying ? .tempoDarkGray : .tempoLightGray
		}
	}
	
	func likedPostViewPressed(_ sender: UIGestureRecognizer) {
		guard let _ = post else { return }
		
		if sender is UITapGestureRecognizer {
			let tapPoint = sender.location(in: self)
			let hitView = hitTest(tapPoint, with: nil)
			if hitView == addButton {
				if songStatus == .notSaved {
					SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
						if success {
							self.songStatus = .saved
							self.updateAddButton()
							self.playerDelegate.didToggleAdd?()
							self.postViewDelegate?.didTapAddButtonForPostView?(true)
						}
					}
				} else if songStatus == .saved {
					SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
						if success {
							self.songStatus = .notSaved
							self.updateAddButton()
							self.playerDelegate.didToggleAdd?()
							self.postViewDelegate?.didTapAddButtonForPostView?(false)
						}
					}
				}
			}
		}
	}
	
	func updateSavedStatus() {
		if let selectedPost = post {
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	func updateAddStatus() {
		if let _ = post {
			updateSavedStatus()
			let image = songStatus == .saved ? UIImage(named: "check") : #imageLiteral(resourceName: "AddButton")
			addButton?.setBackgroundImage(image, for: .normal)
		}
	}
}
