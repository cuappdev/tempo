//
//  PostView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer

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
    let fillColor = UIColor.iceDarkGray
 
    var type: ViewType = .Feed
	var songStatus: SavedSongStatus = .NotSaved
	var delegate: PostViewDelegate?
    private var updateTimer: NSTimer?
    private var notificationHandler: AnyObject?
    
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
                    likesLabel?.text = "\(post.likes) likes"
					let imageName = post.isLiked ? "Heart-Red" : "Heart"
					likedButton?.setImage(UIImage(named: imageName), forState: .Normal)
					updateAddButton()
                    break
				case .History:
					profileNameLabel?.text = post.song.artist
					descriptionLabel?.text = "\(post.song.title)"
					likesLabel?.text = "\(post.likes) likes"
					let imageName = post.isLiked ? "Heart-Red" : "Heart"
					likedButton?.setImage(UIImage(named: imageName), forState: .Normal)
					updateAddButton()
					break
				case .Liked:
					profileNameLabel?.text = post.song.artist
					descriptionLabel?.text = "\(post.song.title)"
					likesLabel?.text = "\(post.likes) likes"
					likedButton!.hidden = true
					updateAddButton()
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
				dateLabel?.text = post.relativeDate()
                
                notificationHandler = NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification,
                    object: post.player,
                    queue: nil, usingBlock: { [weak self] note in
                        self?.updateProfileLabelTextColor()
                        self?.setUpTimer()
                        self?.setNeedsDisplay()
                })
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
	
    private func setUpTimer() {
        if updateTimer == nil && post?.player.isPlaying ?? false {
            // 60 fps
            updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
                target: self, selector: Selector("timerFired:"),
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
            progressGestureRecognizer = UIPanGestureRecognizer(target: self, action: "changeProgress:")
            progressGestureRecognizer?.delegate = self
            progressGestureRecognizer?.delaysTouchesBegan = true
            addGestureRecognizer(progressGestureRecognizer!)
        }
        
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "postViewPressed:")
            tapGestureRecognizer?.delegate = self
            tapGestureRecognizer?.cancelsTouchesInView = false
            addGestureRecognizer(tapGestureRecognizer!)
        }
		
		if longPressGestureRecognizer == nil {
			longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "postViewPressed:")
			longPressGestureRecognizer?.delegate = self
			longPressGestureRecognizer?.minimumPressDuration = 0.5
			longPressGestureRecognizer?.cancelsTouchesInView = false
			addGestureRecognizer(longPressGestureRecognizer!)
		}
		
        avatarImageView?.clipsToBounds = true
        userInteractionEnabled = true
        avatarImageView?.userInteractionEnabled = true
        profileNameLabel?.userInteractionEnabled = true
        
        layer.borderColor = UIColor.iceDarkGray.CGColor
        layer.borderWidth = 0.7
        
        profileNameLabel?.scrollRate = 0
        profileNameLabel?.trailingBuffer = 8.0
        descriptionLabel?.scrollRate = 0
        descriptionLabel?.trailingBuffer = 8.0
        
        profileNameLabel?.type = .Continuous
        profileNameLabel?.fadeLength = 8
        profileNameLabel?.tapToScroll = false
        profileNameLabel?.holdScrolling = true
        profileNameLabel?.animationDelay = 2.0
        
        descriptionLabel?.type = .Continuous
        descriptionLabel?.fadeLength = 8
        descriptionLabel?.tapToScroll = false
        descriptionLabel?.holdScrolling = true
        descriptionLabel?.animationDelay = 2.0
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
        updateProfileLabelTextColor()
        setUpTimer()
    }
    
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = post!.song.title + " · " + post!.song.album
    }
    
    func updateProfileLabelTextColor() {
        let avatarLayer = avatarImageView?.layer
//        let current: AnyObject? = layer.presentationLayer()?.valueForKeyPath("transform.rotation")
        if let layer = avatarLayer {
            layer.transform = CATransform3DIdentity
            layer.removeAnimationForKey("transform.rotation")
        }

        if let post = post {
            let color: UIColor
            let duration = NSTimeInterval(0.3)
            if post.player.isPlaying {
                color = UIColor.iceDarkRed
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
//                if let layer = avatarLayer {
//                    print("\(current)")
//                    
//                }

            }
			
			guard let label = profileNameLabel else { return }
            if !label.textColor.isEqual(color) {
                UIView.transitionWithView(label, duration: duration, options: .TransitionCrossDissolve, animations: {
                    label.textColor = color
                    }, completion: { _ in
                        label.textColor = color
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
        let progress = post?.player.progress ?? 0.0
        
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(),
            CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height))
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == progressGestureRecognizer {
            if let player = post?.player {
                var offsetY:CGFloat = 0.0
                var offsetX:CGFloat = 0.0
                if let superview = superview?.superview?.superview as? UIScrollView {
                    offsetY = superview.contentOffset.y
                    offsetX = superview.contentOffset.x
                }
                let translation = progressGestureRecognizer?.translationInView(self)
                
                if let translation = translation {
                    return ((fabs(translation.x) > fabs(translation.y)) &&
                        (offsetY == 0.0 && offsetX == 0.0)) &&
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
				let name = post.isLiked ? "Heart-Red" : "Heart"
				likesLabel?.text = "\(post.likes) likes"
				likedButton?.setImage(UIImage(named: name), forState: .Normal)
			} else if hitView == addButton {
				if songStatus == .NotSaved {
					SpotifyController.sharedController.saveSpotifyTrack(post) { success in
						if success {
							self.addButton?.setImage(UIImage(named: "Check"), forState: .Normal)
							self.delegate?.didTapAddButtonForPostView?(self)
							self.songStatus = .Saved
						}
					}
				} else if songStatus == .Saved {
					SpotifyController.sharedController.removeSavedSpotifyTrack(post) { success in
						if success {
							self.addButton?.setImage(UIImage(named: "Add"), forState: .Normal)
							self.delegate?.didTapAddButtonForPostView?(self)
							self.songStatus = .NotSaved
						}
					}
				}
			} else if hitView == avatarImageView {
				delegate?.didTapImageForPostView?(self)
			}
		}
	}

}
