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
	
	var songNameLabel: UILabel?
	var songArtistLabel: UILabel?
	var albumArtworkImageView: UIImageView?
	var addButton: UIButton?
	
	let fillColor = UIColor.tempoDarkGray
 
	var songStatus: SavedSongStatus = .notSaved
	var postViewDelegate: PostViewDelegate!
	var playerDelegate: PlayerDelegate!
	
	var playerController: PlayerTableViewController?
	
	var post: Post? {
		didSet {
			// update stuff
			if let post = post {
				albumArtworkImageView?.layer.cornerRadius = 7
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
		
		
		backgroundColor = UIColor.tempoLightGray
		
		albumArtworkImageView = UIImageView(frame: CGRect(x: 20, y: 24, width: 52, height: 52))
		albumArtworkImageView?.clipsToBounds = true
		albumArtworkImageView?.translatesAutoresizingMaskIntoConstraints = true
		addSubview(albumArtworkImageView!)
		
		addButton = UIButton(frame: CGRect(x: frame.width-44, y: 39, width: 22, height: 22))
		addButton?.setBackgroundImage(UIImage(named: "plus"), for: .normal)
		addButton?.translatesAutoresizingMaskIntoConstraints = true
		//this tag makes the hitbox bigger
		addButton?.tag = 1
		addSubview(addButton!)
		
		let labelX = albumArtworkImageView!.frame.origin.x + albumArtworkImageView!.frame.width + 16
		songNameLabel = UILabel(frame: CGRect(x: labelX, y: 21, width: 50, height: 18))
		songNameLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
		songNameLabel?.textColor = UIColor.white
		songNameLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songNameLabel!)
		
		songArtistLabel = UILabel(frame: CGRect(x: labelX, y: 45, width: 50, height: 18))
		songArtistLabel?.font = UIFont(name: "Avenir-book", size: 14)
		songArtistLabel?.textColor = UIColor.descriptionLightGray
		songArtistLabel?.translatesAutoresizingMaskIntoConstraints = false
		addSubview(songArtistLabel!)
		
		let songTopConstraint = NSLayoutConstraint(item: songNameLabel!, attribute: .top, relatedBy: .equal, toItem: albumArtworkImageView, attribute: .top, multiplier: 1, constant: 5)
		let songWidthConstraint = NSLayoutConstraint(item: songNameLabel!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
		let songLeftConstraint = NSLayoutConstraint(item: songNameLabel!, attribute: .left, relatedBy: .equal, toItem: albumArtworkImageView!, attribute: .right, multiplier: 1, constant: 16)
		let songRightConstraint = NSLayoutConstraint(item: songNameLabel!, attribute: .right, relatedBy: .equal, toItem: addButton, attribute: .left, multiplier: 1, constant: -16)
		
		let artistTopConstraint = NSLayoutConstraint(item: songArtistLabel!, attribute: .top, relatedBy: .equal, toItem: songNameLabel, attribute: .bottom, multiplier: 1, constant: 6)
		let artistLeftConstraint = NSLayoutConstraint(item: songArtistLabel!, attribute: .left, relatedBy: .equal, toItem: songNameLabel, attribute: .left, multiplier: 1, constant: 0)
		let artistWidthConstraint = NSLayoutConstraint(item: songArtistLabel!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
		let artistRightConstraint = NSLayoutConstraint(item: songArtistLabel!, attribute: .right, relatedBy: .equal, toItem: songNameLabel, attribute: .right, multiplier: 1, constant: 0)
		
		addConstraints([songTopConstraint, songWidthConstraint, songLeftConstraint, songRightConstraint, artistTopConstraint, artistLeftConstraint, artistWidthConstraint, artistRightConstraint])
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
		
		albumArtworkImageView?.clipsToBounds = true
		isUserInteractionEnabled = true
		
		layer.borderColor = UIColor.tempoDarkGray.cgColor
		layer.borderWidth = 0.7
	}
	
	// Customize view to be able to re-use it for search results.
	func flagAsSearchResultPost() {
		songArtistLabel?.text = post!.song.title + " · " + post!.song.album
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
				self.addButton?.setBackgroundImage(UIImage(named: "plus"), for: .normal)
			}
		}
	}
	
	func updateSongLabel() {
		if let post = post {
			let color: UIColor
			let duration = TimeInterval(0.3)
			if post.player.isPlaying {
				color = UIColor.tempoLightRed
			} else {
				color = UIColor.white
			}
			
			guard let label = songNameLabel else { return }
			if !label.textColor.isEqual(color) {
				UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
					label.textColor = color
				}, completion: { _ in
					label.textColor = color
				})
			}
		}
	}
	
	func updateBackground() {
		if let post = post {
			backgroundColor = post.player.isPlaying ? UIColor.tempoDarkGray : UIColor.tempoLightGray
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
			let image = songStatus == .saved ? UIImage(named: "check") : UIImage(named: "plus")
			addButton?.setBackgroundImage(image, for: .normal)
		}
	}
}
