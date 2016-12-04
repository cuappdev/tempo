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
	fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
	fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
    @IBOutlet var profileNameLabel: UILabel?
    @IBOutlet var avatarImageView: UIImageView?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var spacingConstraint: NSLayoutConstraint?
    @IBOutlet var likesLabel: UILabel?
    @IBOutlet var likedButton: UIButton?
    let fillColor = UIColor.tempoDarkGray
 
    var type: ViewType = .feed
	var songStatus: SavedSongStatus = .notSaved
	var postViewDelegate: PostViewDelegate!
	var playerDelegate: PlayerDelegate!

	var playerController: PlayerTableViewController?
    
    var post: Post? {
        didSet {
            if let post = post {
                switch type {
                case .feed:
					avatarImageView?.layer.cornerRadius = avatarImageView!.bounds.size.width / 2
                    profileNameLabel?.text = "\(post.user.firstName) \(post.user.shortenLastName())"
                    descriptionLabel?.text = "\(post.song.title) · \(post.song.artist)"
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "LikedButton" : "LikeButton"
					likedButton?.setBackgroundImage(UIImage(named: imageName), for: .normal)
					dateLabel?.text = post.relativeDate()
				case .history:
					profileNameLabel?.text = post.song.title
					descriptionLabel?.text = post.song.artist
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "LikedButton" : "LikeButton"
					likedButton?.setBackgroundImage(UIImage(named: imageName), for: .normal)
				}
				
				switch type {
				case .feed:
					avatarImageView?.hnk_setImageFromURL(post.user.imageURL)
				case .history:
					avatarImageView?.hnk_setImageFromURL(post.song.smallArtworkURL ?? URL(fileURLWithPath: ""))
				}
                
                //! TODO: Write something that makes this nice and relative
                //! that updates every minute
				
				if User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] != nil {
					songStatus = .saved
				}
				
            }
        }
    }
	
	// Called from delegate whenever player it toggled
	func updatePlayingStatus() {
		updateProfileLabel()
		updateBackground()
	}
	
	func updateDateLabel() {
		self.dateLabel!.isHidden = true
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				self.dateLabel!.isHidden = false
			}
		}
	}
    
    override func didMoveToWindow() {
        
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postViewPressed(_:)))
            tapGestureRecognizer?.delegate = self
            tapGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(tapGestureRecognizer!)
		}
		
		if longPressGestureRecognizer == nil {
			longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postViewPressed(_:)))
			longPressGestureRecognizer?.delegate = self
			longPressGestureRecognizer?.minimumPressDuration = 0.5
			longPressGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(longPressGestureRecognizer!)
		}
		
        avatarImageView?.clipsToBounds = true
        isUserInteractionEnabled = true
        avatarImageView?.isUserInteractionEnabled = true
        profileNameLabel?.isUserInteractionEnabled = true
        
        layer.borderColor = UIColor.tempoDarkGray.cgColor
        layer.borderWidth = 0.7
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil && dateLabel != nil {
            spacingConstraint?.constant = (dateLabel!.frame.origin.x - superview!.frame.size.width) + 8
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
		likedButton?.tag = 1
        updateProfileLabel()
		updateBackground()
    }
	
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = post!.song.title + " · " + post!.song.album
    }
    
    func updateProfileLabel() {
        let avatarLayer = avatarImageView?.layer
        if let layer = avatarLayer {
            layer.transform = CATransform3DIdentity
            layer.removeAnimation(forKey: "transform.rotation")
        }

        if let post = post {
            let color: UIColor
			let font = UIFont(name: "Avenir-Medium", size: 16)!
            let duration = TimeInterval(0.3)
            if post.player.isPlaying {
                color = .tempoRed
				if type == .feed {
					if let layer = avatarLayer {
						let animation = CABasicAnimation(keyPath: "transform.rotation")
						animation.fromValue = 0
						animation.duration = 3 * M_PI
						animation.toValue = 2 * M_PI
						animation.repeatCount = FLT_MAX
						layer.add(animation, forKey: "transform.rotation")
					}
				}
            } else {
                color = UIColor.white
            }
			
			guard let label = profileNameLabel else { return }
            if !label.textColor.isEqual(color) {
                UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
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
			if type == .feed {
				backgroundColor = post.player.wasPlayed ? .readCellColor : .unreadCellColor
			} else {
				backgroundColor = post.player.isPlaying ? .readCellColor : .unreadCellColor
			}
		}
	}
    

	func postViewPressed(_ sender: UIGestureRecognizer) {
		guard let post = post else { return }
		
		if sender is UITapGestureRecognizer {
			let tapPoint = sender.location(in: self)
			let hitView = hitTest(tapPoint, with: nil)
			let tapPointX = tapPoint.x
			if (tapPointX + 4.0) < (avatarImageView?.frame.maxX)! {
				postViewDelegate?.didTapImageForPostView?(post)
			}
			if hitView == likedButton {
				post.toggleLike()
				updateLikedStatus()
				playerDelegate.didToggleLike!()
			}
		}
	}
	
	func updateLikedStatus() {
		if let post = post {
			let name = post.isLiked ? "LikedButton" : "LikeButton"
			likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
			likedButton?.setBackgroundImage(UIImage(named: name), for: .normal)
		}
	}
}
