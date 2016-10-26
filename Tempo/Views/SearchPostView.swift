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
 
    private var updateTimer: NSTimer?
    private var notificationHandler: AnyObject?
    
    var post: Post? {
        didSet {
            if let handler: AnyObject = notificationHandler {
                NSNotificationCenter.defaultCenter().removeObserver(handler)
            }

            // update stuff
			if let post = post {
				avatarImageView?.layer.cornerRadius = 7
                profileNameLabel?.text = post.song.title
                descriptionLabel?.text = post.song.artist
                
                notificationHandler = NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification,
                    object: post.player,
                    queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] note in
                        self?.updateProfileLabel()
                        
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
                })
            } else {
                updateTimer?.invalidate()
                updateTimer = nil
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
        userInteractionEnabled = true
        avatarImageView?.userInteractionEnabled = true
        profileNameLabel?.userInteractionEnabled = true
        
        layer.borderColor = UIColor.tempoDarkGray.CGColor
        layer.borderWidth = CGFloat(0.7)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
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
    
    func updateProfileLabel() {
        if let post = post {
            var color: UIColor!
			let font = UIFont(name: "Avenir-Medium", size: 14)
            let duration = NSTimeInterval(0.3) as NSTimeInterval
            let label = profileNameLabel!
            if post.player.isPlaying {
                color = UIColor.tempoLightRed
                // Will scroll labels
            } else {
                color = UIColor.whiteColor()
            }
            
            if !label.textColor.isEqual(color) {
                UIView.transitionWithView(label, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
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
			fill = post.player.isPlaying ? 1 : 0
        }
        super.drawRect(rect)
        UIColor.tempoDarkGray.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(),
            CGRect(x: 0, y: 0, width: bounds.width * CGFloat(fill), height: bounds.height))
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
