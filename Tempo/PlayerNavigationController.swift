//
//  PlayerNavigationController.swift
//  Tempo
//
//  Created by Jesse Chen on 10/23/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

let PostLikedStatusChangeNotification = "PostLikedStatusChange"

protocol PostDelegate {
	var currentPost: Post? { get }
}

class PlayerNavigationController: UINavigationController, PostDelegate {

	var playerCell: PlayerCellView!
	let frameHeight = CGFloat(72)
	
	var expandedCell: ExpandedPlayerView!
	let expandedHeight = CGFloat(198)
	
	var postsRef: [Post]?
	var postRefIndex: Int?
	var currentPost: Post? {
		didSet {
			if let newPost = currentPost {
				playerCell.updateCellInfo(newPost)
				expandedCell.updateCellInfo(newPost)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - frameHeight, UIScreen.mainScreen().bounds.width, frameHeight))
		playerFrame.backgroundColor = UIColor.redColor()
		self.view.addSubview(playerFrame)
		playerCell = NSBundle.mainBundle().loadNibNamed("PlayerCellView", owner: self, options: nil).first as? PlayerCellView
		playerCell?.setup(self)
		playerCell?.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, frameHeight)
		playerCell?.userInteractionEnabled = false
		playerFrame.addSubview(playerCell!)
		// Do any additional setup after loading the view.
		
		// Setup expandedCell
		expandedCell = NSBundle.mainBundle().loadNibNamed("ExpandedPlayerView", owner: self, options: nil).first as? ExpandedPlayerView
		expandedCell?.setup(self)
		expandedCell?.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, expandedHeight)
		self.view.addSubview(expandedCell!)
		
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] note in
			if let current = self?.currentPost {
				if current.player == note.object as? Player {
					if let path = self?.postRefIndex {
						var index = path + 1
						if let postsRef = self?.postsRef {
							let count = postsRef.count
							index = (index >= count) ? 0 : index
							self?.postRefIndex = index
							self?.currentPost = postsRef[index]
							self?.currentPost?.player.togglePlaying()
						} else {
							self?.playerCell.updatePlayingStatus()
							self?.expandedCell.updatePlayingStatus()
						}
					}
				}
			}
		}
		
	}
	
	func animateExpandedCell(isExpanding: Bool) {
		UIView.animateWithDuration(0.2) {
			let loc = isExpanding ? self.expandedHeight : CGFloat(0)
			UIView.animateWithDuration(0.2, animations: {
				self.expandedCell.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - loc, UIScreen.mainScreen().bounds.width, self.expandedHeight)
				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
			})
		}
	}
}