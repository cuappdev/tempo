//
//  PostView.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import Haneke
import MediaPlayer
import MarqueeLabel

@objc protocol PostViewDelegate {
	optional func didTapAddButtonForPostView(postView: PostView)
	optional func didLongPressOnCell(postView: PostView)
	optional func didTapImageForPostView(postView: PostView)
}

enum ViewType: Int {
    case Feed
	case History
	case Liked
}

enum SavedSongStatus: Int {
	case NotSaved
	case Saved
	case NotSavedToPlaylist
	case SavedToPlaylist
}

class PostView: UIView, UIGestureRecognizerDelegate {
	private var tapGestureRecognizer: UITapGestureRecognizer?
	private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    @IBOutlet var profileNameLabel: MarqueeLabel?
    @IBOutlet var avatarImageView: UIImageView?
    @IBOutlet var descriptionLabel: MarqueeLabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var spacingConstraint: NSLayoutConstraint?
    @IBOutlet var likesLabel: UILabel?
    @IBOutlet var likedButton: UIButton?
    let fillColor = UIColor.tempoDarkGray
 
    var type: ViewType = .Feed
	var songStatus: SavedSongStatus = .NotSaved
	var delegate: PostViewDelegate?
    private var updateTimer: NSTimer?
    private var notificationHandler: AnyObject?
	var playerController: PlayerTableViewController?
    
    var post: Post? {
        didSet {
            if let handler: AnyObject = notificationHandler {
                NSNotificationCenter.defaultCenter().removeObserver(handler)
            }

            setUpTimer()
            
            // update stuff
            if let post = post {
                switch type {
                case .Feed:
					avatarImageView?.layer.cornerRadius = avatarImageView!.bounds.size.width / 2
                    profileNameLabel?.text = post.user.name
                    descriptionLabel?.text = "\(post.song.title) · \(post.song.artist)"
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "filled-heart" : "empty-heart"
					likedButton?.setImage(UIImage(named: imageName), forState: .Normal)
					dateLabel?.text = post.relativeDate()
				case .History:
					avatarImageView?.layer.cornerRadius = 7
					profileNameLabel?.text = post.song.title
					descriptionLabel?.text = post.song.artist
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "filled-heart" : "empty-heart"
					likedButton?.setImage(UIImage(named: imageName), forState: .Normal)
				case .Liked:
					avatarImageView?.layer.cornerRadius = 7
					profileNameLabel?.text = post.song.title
					descriptionLabel?.text = post.song.artist
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					likedButton!.hidden = true
					dateLabel?.hidden = true
				}
				
				switch type {
				case .Feed:
					avatarImageView?.hnk_setImageFromURL(post.user.imageURL)
				case .History, .Liked:
					avatarImageView?.hnk_setImageFromURL(post.song.smallArtworkURL ?? NSURL())
				}
                
                //! TODO: Write something that makes this nice and relative
                //! that updates every minute
				
                
                notificationHandler = NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification,
                    object: post.player,
                    queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] note in
                        self?.updateProfileLabel()
                        self?.setUpTimer()
                        self?.setNeedsDisplay()
                })
				
				if (User.currentUser.currentSpotifyUser?.savedTracks[post.song.spotifyID] != nil) ?? false {
					songStatus = .Saved
				}
				
            }
        }
    }
	
	func updateDateLabel() {
		self.dateLabel!.hidden = true
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				self.dateLabel!.hidden = false
			}
		}
	}
	
    private func setUpTimer() {
        if updateTimer == nil && post?.player.isPlaying ?? false {
            // 60 fps
            updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
                target: self, selector: #selector(timerFired(_:)),
                userInfo: nil,
                repeats: true)

            NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
        } else if !(post?.player.isPlaying ?? false) {
            updateTimer?.invalidate()
            updateTimer = nil
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
        userInteractionEnabled = true
        avatarImageView?.userInteractionEnabled = true
        profileNameLabel?.userInteractionEnabled = true
        
        layer.borderColor = UIColor.tempoDarkGray.CGColor
        layer.borderWidth = 0.7
		
		self.setupMarqueeLabel(profileNameLabel!)
		self.setupMarqueeLabel(descriptionLabel!)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil && dateLabel != nil {
            spacingConstraint?.constant = (dateLabel!.frame.origin.x - superview!.frame.size.width) + 8
        }
    }
    
    dynamic private func timerFired(timer: NSTimer) {
        if post?.player.isPlaying ?? false {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        updateProfileLabel()
        setUpTimer()
    }
	
	private func setupMarqueeLabel(label: MarqueeLabel) {
		label.speed = .Duration(8)
		label.trailingBuffer = 10
		label.type = .Continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = post!.song.title + " · " + post!.song.album
    }
    
    func updateProfileLabel() {
        let avatarLayer = avatarImageView?.layer
        if let layer = avatarLayer {
            layer.transform = CATransform3DIdentity
            layer.removeAnimationForKey("transform.rotation")
        }

        if let post = post {
            let color: UIColor
			let font = UIFont(name: "Avenir-Medium", size: 16)!
            let duration = NSTimeInterval(0.3)
            if post.player.isPlaying {
                color = UIColor.tempoLightRed
				if type == .Feed {
					if let layer = avatarLayer {
						let animation = CABasicAnimation(keyPath: "transform.rotation")
						animation.fromValue = 0
						animation.duration = 3 * M_PI
						animation.toValue = 2 * M_PI
						animation.repeatCount = FLT_MAX
						layer.addAnimation(animation, forKey: "transform.rotation")
					}
				}
				
                // Will scroll labels
                profileNameLabel?.holdScrolling = false
                descriptionLabel?.holdScrolling = false
            } else {
                color = UIColor.whiteColor()
                // Labels won't scroll
                profileNameLabel?.holdScrolling = true
                descriptionLabel?.holdScrolling = true
            }
			
			guard let label = profileNameLabel else { return }
            if !label.textColor.isEqual(color) {
                UIView.transitionWithView(label, duration: duration, options: .TransitionCrossDissolve, animations: {
                    label.textColor = color
					label.font = font
                    }, completion: { _ in
                        label.textColor = color
						label.font = font
                })
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
		var fill = 0
		if let post = post {
			if type == .Feed {
				fill = post.player.wasPlayed ? 1 : 0
			} else {
				fill = post.player.isPlaying ? 1 : 0
			 }
		}
        
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(),
            CGRect(x: 0, y: 0, width: bounds.width * CGFloat(fill), height: bounds.height))
    }
    
	func postViewPressed(sender: UIGestureRecognizer) {
		guard let post = post else { return }
		
		if sender.isKindOfClass(UILongPressGestureRecognizer) {
			if sender.state == .Began {
				delegate?.didLongPressOnCell?(self)
			}
		} else if sender.isKindOfClass(UITapGestureRecognizer) {
			let tapPoint = sender.locationInView(self)
			let hitView = hitTest(tapPoint, withEvent: nil)
			if hitView == likedButton {
				post.toggleLike()
				let name = post.isLiked ? "filled-heart" : "empty-heart"
				likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
				likedButton?.setImage(UIImage(named: name), forState: .Normal)
			} else if hitView == avatarImageView {
				delegate?.didTapImageForPostView?(self)
			}
		}
	}
}
