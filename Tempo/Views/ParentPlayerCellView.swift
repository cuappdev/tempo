//
//  ParentPlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 11/25/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ParentPlayerCellView: UIView {

	internal var postsLikable: Bool?
	
	var playerNav: PlayerNavigationController!
	
	var songStatus: SavedSongStatus = .notSaved
	var post: Post?
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
	
	//Responsible for updating song status (saved vs. notSaved)
	func updateSongStatus() {
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
		preconditionFailure("This method must be overridden")
	}
	
	//Visual update for add button, based on whether the song is saved or notSaved
	func updateAddButton() {
		preconditionFailure("This method must be overriden")
	}
	
	//Clears any playing song, resets all labels to default state
	func resetPlayerCell() {
		preconditionFailure("This method must be overridden")
	}
}
