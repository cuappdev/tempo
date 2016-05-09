//
//  SearchPostView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer
import MarqueeLabel

class SearchPostView: UIView, UIGestureRecognizerDelegate {
	private var progressGestureRecognizer: UIPanGestureRecognizer?
	var tapGestureRecognizer: UITapGestureRecognizer?
	@IBOutlet var profileNameLabel: MarqueeLabel?
	@IBOutlet var avatarImageView: FeedImageView?
	@IBOutlet var descriptionLabel: MarqueeLabel?
	@IBOutlet var dateLabel: UILabel?
	@IBOutlet var spacingConstraint: NSLayoutConstraint?
 
	private var updateTimer: NSTimer?
	private var notificationHandler: AnyObject?
	
	var post: Post? {
		didSet {
			if let handler = notificationHandler {
				NSNotificationCenter.defaultCenter().removeObserver(handler)
			}
			
			// update stuff
			guard let post = post else {
				updateTimer?.invalidate()
				updateTimer = nil
				return
			}
			
			profileNameLabel?.text = post.song.title
			descriptionLabel?.text = post.song.artist
			
			notificationHandler = NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification, object: post.player, queue: NSOperationQueue.mainQueue()) { [weak self] note in
				self?.updateProfileLabelTextColor()
				
				if self?.updateTimer == nil && self?.post?.player.isPlaying ?? false {
					// 60 fps
					self?.updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
					                            target: self!, selector: #selector(SearchPostView.timerFired(_:)),
					                            userInfo: nil,
					                            repeats: true)
					NSRunLoop.currentRunLoop().addTimer(self!.updateTimer!, forMode: NSRunLoopCommonModes)
				} else {
					self?.updateTimer?.invalidate()
					self?.updateTimer = nil
				}
			}
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
		
		avatarImageView?.clipsToBounds = true
		userInteractionEnabled = true
		avatarImageView?.userInteractionEnabled = true
		profileNameLabel?.userInteractionEnabled = true
		
		layer.borderColor = UIColor.iceDarkGray.CGColor
		layer.borderWidth = CGFloat(0.7)
		
		profileNameLabel?.speed = .Rate(0)
		profileNameLabel?.trailingBuffer = 8
		descriptionLabel?.speed = .Rate(0)
		descriptionLabel?.trailingBuffer = 8
		
		profileNameLabel?.type = .Continuous
		profileNameLabel?.fadeLength = 8
		profileNameLabel?.tapToScroll = false
		profileNameLabel?.holdScrolling = true
		profileNameLabel?.animationDelay = 2
		
		descriptionLabel?.type = .Continuous
		descriptionLabel?.fadeLength = 8
		descriptionLabel?.tapToScroll = false
		descriptionLabel?.holdScrolling = true
		descriptionLabel?.animationDelay = 2
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
	
	// Customize view to be able to re-use it for search results.
	func flagAsSearchResultPost() {
		descriptionLabel?.text = post!.song.title + " · " + post!.song.album
	}
	
	func updateProfileLabelTextColor() {
		if let post = post {
			var color: UIColor!
			let duration = NSTimeInterval(0.3) as NSTimeInterval
			let label = profileNameLabel!
			if post.player.isPlaying {
				color = UIColor.iceDarkRed
				// Will scroll labels
				profileNameLabel?.holdScrolling = false
				descriptionLabel?.holdScrolling = false
			} else {
				color = UIColor.whiteColor()
				// Labels won't scroll
				profileNameLabel?.holdScrolling = true
				descriptionLabel?.holdScrolling = true
			}
			
			if !label.textColor.isEqual(color) {
				UIView.transitionWithView(label, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
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
		var progress = 0.0
		if let post = post {
			progress = post.player.progress
		}
		super.drawRect(rect)
		UIColor.iceDarkGray.setFill()
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
				let translation = self.progressGestureRecognizer?.translationInView(self)
				
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
	
	func postViewPressed(sender: UITapGestureRecognizer) {
		if let post = post {
			if post.player.isPlaying {
				let tapPoint = sender.locationInView(self)
				let hitView = hitTest(tapPoint, withEvent: nil)
				
				if hitView == avatarImageView || hitView == profileNameLabel {
					// GO TO PROFILE VIEW CONTROLLER=
				}
			}
		}
	}
}
