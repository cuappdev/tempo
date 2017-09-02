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

class LikedPostView: PostView {
	fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
	fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
	
	let artworkImageLength: CGFloat = 54
	let addButtonLength: CGFloat = 20
	let padding: CGFloat = 22
	let addButtonPadding: CGFloat = 17
	let separatorHeight: CGFloat = 1
	
	var labelWidth: CGFloat = 0
	var isSpotifyAvailable: Bool = false
	
	var songNameLabel: UILabel?
	var songArtistLabel: UILabel?
	var albumArtworkImageView: UIImageView?
	var addButton: UIButton?

	var songStatus: SavedSongStatus = .notSaved
	var postViewDelegate: PostViewDelegate!
	var playerDelegate: PlayerDelegate!
	
	var playerController: PlayerTableViewController?
	
	override var post: Post? {
		didSet {
			// update stuff
			if let post = post {
				songNameLabel?.text = post.song.title
				songArtistLabel?.text = post.song.artist
				
				albumArtworkImageView?.hnk_setImageFromURL(post.song.smallArtworkURL ?? URL(fileURLWithPath: ""))
				
				if let _ = User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] {
					songStatus = .saved
				}
				
				updateAddButton()
			}
		}
	}

	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		backgroundColor = .unreadCellColor
		
		albumArtworkImageView = UIImageView(frame: CGRect(x: padding, y: padding, width: artworkImageLength, height: artworkImageLength))
		albumArtworkImageView?.center.y = center.y
		albumArtworkImageView?.clipsToBounds = true
		albumArtworkImageView?.translatesAutoresizingMaskIntoConstraints = true
		addSubview(albumArtworkImageView!)

		let labelX = (albumArtworkImageView?.frame.maxX)! + padding
		let shorterlabelWidth = bounds.width - labelX - addButtonLength - 2*addButtonPadding
		let longerLabelWidth = bounds.width - labelX - padding
		let currLabelWidth = isSpotifyAvailable ? shorterlabelWidth : longerLabelWidth
		
		songNameLabel = UILabel(frame: CGRect(x: labelX, y: padding, width: currLabelWidth, height: 22))
		songNameLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		songNameLabel?.textColor = .white
		songNameLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songNameLabel!)
		
		songArtistLabel = UILabel(frame: CGRect(x: labelX, y: (songNameLabel?.frame.maxY)! + 2, width: currLabelWidth, height: 22))
		songArtistLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		songArtistLabel?.textColor = .paleRed
		songArtistLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songArtistLabel!)
		
		addButton = UIButton(frame: CGRect(x: frame.width - addButtonLength - addButtonPadding, y: 34, width: addButtonLength, height: addButtonLength))
		addButton?.center.y = center.y
		addButton?.setBackgroundImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
		addButton?.translatesAutoresizingMaskIntoConstraints = true
		addButton?.tag = 1 // this tag makes the hitbox bigger
		addButton?.isHidden = !isSpotifyAvailable
		addSubview(addButton!)
	}
	
	override func updatePlayingStatus() {
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
		if let _ = post {
			if songStatus == .saved {
				self.addButton?.setBackgroundImage(#imageLiteral(resourceName: "AddedButton"), for: .normal)
			} else {
				self.addButton?.setBackgroundImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
			}
		}
	}
	
	func updateSongLabel() {
		if let post = post {
			let duration = TimeInterval(0.3)
			let color: UIColor = post.player?.isPlaying ?? false ? .tempoRed : .white
			let font: UIFont = post.player?.isPlaying ?? false ? UIFont(name: "AvenirNext-Medium", size: 16.0)! : UIFont(name: "AvenirNext-Regular", size: 16.0)!
			
			guard let label = songNameLabel else { return }
			if !label.textColor.isEqual(color) {
				UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
					label.textColor = color
					label.font = font
				})
			}
		}
	}
	
	func updateViews() {
		if isSpotifyAvailable {
			songNameLabel?.frame.size.width = labelWidth
			songArtistLabel?.frame.size.width = labelWidth
			addButton!.isHidden = false
		} else {
			let newLabelWidth = bounds.width - (songNameLabel?.frame.minX)! - padding
			songNameLabel?.frame.size.width = newLabelWidth
			songArtistLabel?.frame.size.width = newLabelWidth
			
			addButton!.isHidden = true
		}
	}
	
	override func updateBackground() {
		if let post = post {
			backgroundColor = post.player?.isPlaying ?? false ? .readCellColor : .unreadCellColor
		}
	}
	
	func likedPostViewPressed(_ sender: UIGestureRecognizer) {
		// MARK: TODO
//		guard let _ = post else { return }
//		
//		if sender is UITapGestureRecognizer {
//			let tapPoint = sender.location(in: self)
//			let hitView = hitTest(tapPoint, with: nil)
//			if hitView == addButton {
//				if songStatus == .notSaved {
//					SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
//						if success {
//							self.songStatus = .saved
//							self.updateAddButton()
//							self.playerDelegate.didToggleAdd?()
//							self.postViewDelegate?.didTapAddButtonForPostView?(true)
//						}
//					}
//				} else if songStatus == .saved {
//					SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
//						if success {
//							self.songStatus = .notSaved
//							self.updateAddButton()
//							self.playerDelegate.didToggleAdd?()
//							self.postViewDelegate?.didTapAddButtonForPostView?(false)
//						}
//					}
//				}
//			}
//		}
	}
	
	func updateSavedStatus() {
		if let selectedPost = post {
			if let _ = User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] {
				songStatus = .saved
			} else {
				songStatus = .notSaved
			}
		}
	}
	
	func updateAddStatus() {
		if let _ = post {
			updateSavedStatus()
			let image = (songStatus == .saved) ? #imageLiteral(resourceName: "AddedButton") : #imageLiteral(resourceName: "AddButton")
			addButton?.setBackgroundImage(image, for: .normal)
		}
	}
}
