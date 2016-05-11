//
//  PostView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
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
    private var progressGestureRecognizer: UIPanGestureRecognizer?
	private var tapGestureRecognizer: UITapGestureRecognizer?
	private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    @IBOutlet var profileNameLabel: MarqueeLabel?
    @IBOutlet var avatarImageView: FeedImageView?
    @IBOutlet var descriptionLabel: MarqueeLabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var spacingConstraint: NSLayoutConstraint?
    @IBOutlet var likesLabel: UILabel?
    @IBOutlet var likedButton: UIButton?
    @IBOutlet var addButton: UIButton?
    let fillColor = UIColor.tempoDarkGray
 
    var type: ViewType = .Feed
	var songStatus: SavedSongStatus = .NotSaved
	var delegate: PostViewDelegate?
    private var updateTimer: NSTimer?
    private var notificationHandler: AnyObject?
	var pinned = false
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
					updateAddButton()
                    break
				case .History:
					profileNameLabel?.text = post.song.artist
					descriptionLabel?.text = "\(post.song.title)"
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					let imageName = post.isLiked ? "filled-heart" : "empty-heart"
					likedButton?.setImage(UIImage(named: imageName), forState: .Normal)
					dateLabel?.text = post.relativeDate()
					updateAddButton()
					break
				case .Liked:
					self.addButton!.frame.origin.x = self.likedButton!.frame.origin.x
					self.addButton!.frame.origin.y = self.likedButton!.frame.origin.y
					profileNameLabel?.text = post.song.artist
					descriptionLabel?.text = "\(post.song.title)"
					likesLabel?.text = (post.likes == 1) ? "\(post.likes) like" : "\(post.likes) likes"
					likedButton!.hidden = true
					dateLabel?.text = "Add to Spotify"
					updateAddButton()
					updateDateLabel()
				}
                if type == .Feed {
                    post.user.loadImage {
                        self.avatarImageView?.image = $0
                    }
                }
				else if type == .History || type == .Liked {
					avatarImageView!.imageURL = post.song.smallArtworkURL
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
					self.addButton?.setImage(UIImage(named: "check"), forState: .Normal)
					songStatus = .Saved
				}
				
            }
        }
    }
	
	func updateAddButton() {
		addButton!.hidden = true
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				self.addButton!.hidden = false
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
        if progressGestureRecognizer == nil {
            progressGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(changeProgress(_:)))
            progressGestureRecognizer?.delegate = self
            progressGestureRecognizer?.delaysTouchesBegan = true
            addGestureRecognizer(progressGestureRecognizer!)
        }
        
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
		label.speed = .Duration(4.6)
		label.trailingBuffer = 10
		label.type = .Continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 2
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
			let font: UIFont
            let duration = NSTimeInterval(0.3)
            if post.player.isPlaying {
                color = UIColor.tempoLightRed
				font = UIFont(name: "Avenir-Heavy", size: 14)!
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
				font = UIFont(name: "Avenir-Medium", size: 14)!
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
    
    dynamic func changeProgress(gesture: UIPanGestureRecognizer) {
        if gesture.state != .Ended {
            post?.player.pause(false)
        } else {
            post?.player.play(false)
        }
        
        let xTranslation = gesture.locationInView(self).x
        let cellWidth = bounds.width
        
        let progress = Double(xTranslation/cellWidth)
        post?.player.progress = progress
        
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let progress = post?.player.progress ?? 0
        
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(),
            CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height))
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == progressGestureRecognizer {
            if let player = post?.player {
                var offsetY: CGFloat = 0
                var offsetX: CGFloat = 0
                if let superview = superview?.superview?.superview as? UIScrollView {
                    offsetY = superview.contentOffset.y
                    offsetX = superview.contentOffset.x
                }
                let translation = progressGestureRecognizer?.translationInView(self)
                
                if let translation = translation {
                    return ((fabs(translation.x) > fabs(translation.y)) &&
                        (offsetY == 0 && offsetX == 0)) &&
                        player.isPlaying
                }
            }
            return false
		}
        return true
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
			} else if hitView == addButton {
				if songStatus == .NotSaved {
					SpotifyController.sharedController.saveSpotifyTrack(post) { success in
						if success {
							self.addButton?.setImage(UIImage(named: "check"), forState: .Normal)
							self.delegate?.didTapAddButtonForPostView?(self)
							self.songStatus = .Saved
						}
					}
				} else if songStatus == .Saved {
					SpotifyController.sharedController.removeSavedSpotifyTrack(post) { success in
						if success {
							self.addButton?.setImage(UIImage(named: "plus"), forState: .Normal)
							self.delegate?.didTapAddButtonForPostView?(self)
							self.songStatus = .NotSaved
						}
					}
				}
			} else if hitView == avatarImageView {
				delegate?.didTapImageForPostView?(self)
			} else if pinned {
				if let playerController = playerController {
					playerController.togglePlay()
				}
			}
		}
	}
}
