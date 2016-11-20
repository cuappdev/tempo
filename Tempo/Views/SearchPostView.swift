//
//  SearchPostView.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchPostView: UIView, UIGestureRecognizerDelegate {
	var tapGestureRecognizer: UITapGestureRecognizer?
	@IBOutlet var profileNameLabel: UILabel?
	@IBOutlet var avatarImageView: UIImageView?
	@IBOutlet var descriptionLabel: UILabel?
	@IBOutlet var spacingConstraint: NSLayoutConstraint?
    
    var post: Post? {
        didSet {
            // update stuff
			if let post = post {
				avatarImageView?.layer.cornerRadius = 7
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
        
        layer.borderColor = UIColor.tempoDarkGray.cgColor
        layer.borderWidth = CGFloat(0.7)
		
		descriptionLabel?.textColor = UIColor.descriptionLightGray
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
	
	func updatePlayingStatus() {
		updateProfileLabel()
		updateBackground()
	}
	
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = post!.song.title + " · " + post!.song.album
    }
    
    func updateProfileLabel() {
        if let post = post {
            var color: UIColor!
			let font = UIFont(name: "Avenir-Medium", size: 14)
            let duration = TimeInterval(0.3) as TimeInterval
            let label = profileNameLabel!
            if post.player.isPlaying {
                color = UIColor.tempoLightRed
                // Will scroll labels
            } else {
                color = UIColor.white
            }
            
            if !label.textColor.isEqual(color) {
                UIView.transition(with: label, duration: duration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    label.textColor = color
					label.font = font
                    }, completion: { _ in
                        label.textColor = color
						label.font = font
                })
            }
        }
	}
	
	func updateBackground() {
		if let post = post {
			backgroundColor = post.player.isPlaying ? UIColor.tempoDarkGray : UIColor.tempoLightGray
		}
	}
    
    func postViewPressed(_ sender: UITapGestureRecognizer) {
        if let post = post {
            if post.player.isPlaying {
                let tapPoint = sender.location(in: self)
                let hitView = hitTest(tapPoint, with: nil)
                
                if hitView == avatarImageView || hitView == profileNameLabel {
                    // GO TO PROFILE VIEW CONTROLLER=
                }
            }
        }
    }
}
