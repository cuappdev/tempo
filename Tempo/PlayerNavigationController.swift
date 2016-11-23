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
	let expandedHeight = CGFloat(347)
	
	var postsRef: [Post]?
	var postRefIndex: Int?
	var currentPost: Post? {
		didSet {
			if let newPost = currentPost {
				updatePlayerCells(newPost: newPost)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - frameHeight, width: UIScreen.main.bounds.width, height: frameHeight))
		playerFrame.backgroundColor = .red
		view.addSubview(playerFrame)
		playerCell = Bundle.main.loadNibNamed("PlayerCellView", owner: self, options: nil)?.first as? PlayerCellView
		playerCell?.setup(parent: self)
		playerCell?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frameHeight)
		playerCell?.isUserInteractionEnabled = false
		playerFrame.addSubview(playerCell!)
		// Do any additional setup after loading the view.
		
		// Setup expandedCell
		expandedCell = Bundle.main.loadNibNamed("ExpandedPlayerView", owner: self, options: nil)?.first as? ExpandedPlayerView
		expandedCell?.setup(parent: self)
		expandedCell?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: expandedHeight)
		view.addSubview(expandedCell!)
	}
	
	func updatePlayerCells(newPost: Post) {
		playerCell.updateCellInfo(newPost: newPost)
		expandedCell.updateCellInfo(newPost: newPost)
	}
	
	func animateExpandedCell(isExpanding: Bool) {
		UIView.animate(withDuration: 0.2) {
			let loc = isExpanding ? self.expandedHeight : CGFloat(0)
			UIView.animate(withDuration: 0.2, animations: {
				self.expandedCell.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - loc, width: UIScreen.main.bounds.width, height: self.expandedHeight)
				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
			})
		}
	}
	
	func updateDelegates(delegate: PlayerDelegate) {
		playerCell.delegate = delegate
		expandedCell.delegate = delegate
	}
	
	func resetPlayerCells() {
		currentPost = nil
		playerCell.resetPlayerCell()
		expandedCell.resetPlayerCell()
	}
	
	func updatePlayingStatus() {
		playerCell.updatePlayingStatus()
		expandedCell.updatePlayingStatus()
	}
	
	func updateLikeButton() {
		playerCell.updateLikeButton()
		expandedCell.updateLikeButton()
	}
}
