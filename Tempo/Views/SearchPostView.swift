//
//  SearchPostView.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchPostView: PostView {
	var tapGestureRecognizer: UITapGestureRecognizer?
	@IBOutlet var profileNameLabel: UILabel?
	@IBOutlet var avatarImageView: UIImageView?
	@IBOutlet var descriptionLabel: UILabel?
	@IBOutlet var spacingConstraint: NSLayoutConstraint?
    
    override var post: Post? {
        didSet {
            // update stuff
			if let post = post {
                profileNameLabel?.text = post.song.title
                descriptionLabel?.text = post.song.artist
            }
        }
    }
    
    override func didMoveToWindow() {
        
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchPostView.postViewPressed(_:)))
            tapGestureRecognizer?.delegate = self
            tapGestureRecognizer?.cancelsTouchesInView = false
            addGestureRecognizer(tapGestureRecognizer!)
        }
        
        avatarImageView?.clipsToBounds = true
        isUserInteractionEnabled = true
        avatarImageView?.isUserInteractionEnabled = true
        profileNameLabel?.isUserInteractionEnabled = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
	
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = "\(post!.song.title) · \(post!.song.album)"
    }
    
    override func updateProfileLabel() {
        if let post = post {
            let duration = TimeInterval(0.3)
			let color: UIColor = post.player?.isPlaying ?? false ? .tempoRed : .white
			let font: UIFont = post.player?.isPlaying ?? false ? UIFont(name: "AvenirNext-Medium", size: 16.0)! : UIFont(name: "AvenirNext-Regular", size: 16.0)!
   
			guard let label = profileNameLabel else { return }
            if !label.textColor.isEqual(color) {
                UIView.transition(with: label, duration: duration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    label.textColor = color
					label.font = font
				})
            }
        }
	}
	
	override func updateBackground() {
		if let post = post {
			backgroundColor = post.player?.isPlaying ?? false ? .readCellColor : .unreadCellColor
		}
	}
    
    func postViewPressed(_ sender: UITapGestureRecognizer) {
        if let post = post {
            if post.player?.isPlaying ?? false {
                let tapPoint = sender.location(in: self)
                let hitView = hitTest(tapPoint, with: nil)
                
                if hitView == avatarImageView || hitView == profileNameLabel {
                    // GO TO PROFILE VIEW CONTROLLER=
                }
            }
        }
    }
}
