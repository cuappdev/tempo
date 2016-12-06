//
//  ParentPlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 11/25/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ParentPlayerCellView: UIView {

	var playerNav: PlayerNavigationController!
	var songStatus: SavedSongStatus = .notSaved
	var post: Post?
	var postsLikable: Bool?
	
	weak var delegate: PlayerDelegate? {
		didSet {
			postsLikable = delegate is FeedViewController
		}
	}
	
	//Initial setup
	func setup() {
		preconditionFailure("This method must be overridden")
	}
	
	//Responsible for updating the post, labels, images, etc.
	func updateCellInfo(newPost: Post) {
		preconditionFailure("This method must be overridden")
	}
	
	//Responsible for updating saved status (saved vs. notSaved)
	func updateSavedStatus() {
		preconditionFailure("This method must be overridden")
	}
	
	//Responsible for checking whether the song is playing, calls updatePlayToggleButton()
	func updatePlayingStatus() {
		preconditionFailure("This method must be overridden")
	}
	
	//Visual update for playToggleButton, based on whether the song is playing or not
	func updatePlayToggleButton() {
		preconditionFailure("This method must be overridden")
	}
	
	//Switches saved to notSaved, or notSaved to saved, and calls updateAddButton()
	func toggleAddButton() {
		if let _ = User.currentUser.currentSpotifyUser {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success && songStatus == .notSaved {
					SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
						if success {
							self.playerNav?.playerCell.updateAddButton()
							self.playerNav?.expandedCell.updateAddButton()
							self.delegate?.didToggleAdd?()
						}
					}
				} else if success && songStatus == .saved {
					SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
						if success {
							self.playerNav?.playerCell.updateAddButton()
							self.playerNav?.expandedCell.updateAddButton()
							self.delegate?.didToggleAdd?()
						}
					}
				}
			}
		} else {
			//bring them to settingsVC
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let playerNav = appDelegate.navigationController
			let settingsVC = appDelegate.settingsVC
			settingsVC.shouldAddHamburger = false
			settingsVC.navigationItem.leftBarButtonItem = nil //clear existing hamburgerMenu, if there
			playerNav.pushViewController(settingsVC, animated: true)
		}
	}
	
	//Visual update for add button, based on whether the song is saved or notSaved
	func updateAddButton() {
		preconditionFailure("This method must be overriden")
	}
	
	//Clears any playing song, resets all labels to default state
	func resetPlayerCell() {
		post = nil
	}
}
