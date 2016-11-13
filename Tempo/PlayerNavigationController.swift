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
				updatePlayerCells(newPost)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - frameHeight, UIScreen.mainScreen().bounds.width, frameHeight))
		playerFrame.backgroundColor = UIColor.redColor()
		view.addSubview(playerFrame)
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
		view.addSubview(expandedCell!)
	}
	
	func updateCellDelegates(delegate: PlayerDelegate) {
		playerCell.delegate = delegate
		expandedCell.delegate = delegate
	}
	
	func updatePlayerCells(newPost: Post) {
		playerCell.updateCellInfo(newPost)
		expandedCell.updateCellInfo(newPost)
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
	
	func resetPlayerCells() {
		playerCell.resetPlayerCell()
		expandedCell.resetPlayerCell()
	}
}