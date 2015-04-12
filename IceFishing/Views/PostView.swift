//
//  PostView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class PostView: UIView, UIGestureRecognizerDelegate {
    private var progressGestureRecognizer: UIPanGestureRecognizer?
    @IBOutlet var profileNameLabel: UILabel?
    @IBOutlet var avatarImageView: UIImageView?
    @IBOutlet var descriptionLabel: UILabel?
    var fillColor = UIColor.blackColor()
    private var updateTimer: NSTimer?
    
    var post: Post? {
        didSet {
            // update stuff
            if let post = post {
                profileNameLabel?.text = post.posterFirstName + " " + post.posterLastName
                descriptionLabel?.text = post.song.title + " - " + post.song.artist
                avatarImageView?.image = post.avatar
                
                updateTimer = NSTimer(timeInterval: 0.1,
                    target: self, selector: Selector("timerFired:"),
                    userInfo: nil,
                    repeats: true)
                NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
            } else {
                updateTimer?.invalidate()
                updateTimer = nil
            }
        }
    }
    
    override func didMoveToWindow() {
        progressGestureRecognizer = UIPanGestureRecognizer(target: self, action: "changeProgress:")
        progressGestureRecognizer?.delegate = self
        addGestureRecognizer(progressGestureRecognizer!)
        
        avatarImageView?.layer.cornerRadius = avatarImageView!.bounds.size.width / 2
        avatarImageView?.clipsToBounds = true
        
        avatarImageView?.userInteractionEnabled = true
        profileNameLabel?.userInteractionEnabled = true
    }
    
    dynamic private func timerFired(timer: NSTimer) {
        self.setNeedsDisplay()
    }
    
    dynamic func changeProgress(gesture: UIPanGestureRecognizer) {
        if (gesture.state != .Ended) {
            post?.player.pause();
        } else {
            post?.player.play();
        }
        
        var xTranslation = gesture.locationInView(self).x
        var cellWidth = bounds.width
        
        let progress = Double(xTranslation/cellWidth)
        post?.player.progress = progress
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        var progress = 0.0
        if let post = post {
            progress = post.player.progress
        }
        
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(),
            CGRect(x: 0, y: 0,
                width: self.bounds.size.width * CGFloat(progress),
                height: self.bounds.size.height))
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.progressGestureRecognizer {
            if let player = post?.player {
                var offsetY:CGFloat = 0.0
                var offsetX:CGFloat = 0.0
                if let superview = self.superview?.superview?.superview as? UIScrollView {
                    offsetY = superview.contentOffset.y
                    offsetX = superview.contentOffset.x
                }
                var translation = self.progressGestureRecognizer?.translationInView(self)
                
                if let translation = translation {
                    return ((fabs(translation.x) / fabs(translation.y) > 1) &&
                        (offsetY == 0.0 && offsetX == 0.0)) &&
                        player.isPlaying()
                }
            }
            
            return false
        }
        return true
    }

}
