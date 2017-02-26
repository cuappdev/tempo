//
//  PostView.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer
import Haneke

@objc protocol PostViewDelegate {
	@objc optional func didTapAddButtonForPostView(_ saved: Bool)
	@objc optional func didTapImageForPostView(_ post: Post)
}

enum ViewType: Int {
	case feed
	case history
}

enum SavedSongStatus: Int {
	case notSaved
	case saved
	case notSavedToPlaylist
	case savedToPlaylist
}

class PostView: UIView, UIGestureRecognizerDelegate {
	
	var post: Post?

	// Called from delegate whenever player is toggled
	func updatePlayingStatus() {
		updateProfileLabel()
		updateBackground()
	}
	
	func updateProfileLabel(){
		preconditionFailure("This method must be overriden")
	}
	
	func updateBackground(){
		preconditionFailure("This method must be overriden")
	}
	
	override func didMoveToWindow() {
		preconditionFailure("This method must be overriden")
	}
}
