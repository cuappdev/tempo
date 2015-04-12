//
//  FeedTableViewCell.swift
//  experience
//
//  Created by Mark Bryan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    var progressGestureRecognizer: UIPanGestureRecognizer?
    var songID: NSURL!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var songDescriptionLabel: UILabel!
    private var timer: NSTimer?
    var progress: Double = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var player: Player? {
        didSet {
            if (player == nil) {
                self.timer?.invalidate()
                self.timer = nil
            }
            
            player?.callBack = {
                [unowned self]
                (isPlaying) in
                self.player?.progress = self.progress
                
                if (isPlaying) {
                    self.timer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
                    NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
                    
                } else {
                    self.timer?.invalidate()
                    self.progress=0;
                    self.timer = nil
                }
                
                self.setNeedsDisplay()
                
                if let callBack = self.callBack {
                    callBack(isPlaying: isPlaying, sender: self)
                }
            }
        }
    }
    var callBack: ((isPlaying: Bool, sender: FeedTableViewCell) -> Void)?
    
    var fillColor: UIColor = UIColor.grayColor()
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var songPostTimeLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    dynamic private func timerFired(timer: NSTimer) {
        if let player = player {
            self.progress = player.progress
        }
    }
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        
        progressGestureRecognizer = UIPanGestureRecognizer(target: self, action: "changeProgress:")
        progressGestureRecognizer?.delegate = self
        addGestureRecognizer(progressGestureRecognizer!)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "cellPressed:")
        tapRecognizer.cancelsTouchesInView = false
        //ADDED
        addGestureRecognizer(tapRecognizer)
        
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width/2
        avatarImageView.clipsToBounds = true
        
        avatarImageView.userInteractionEnabled = true
        profileNameLabel.userInteractionEnabled = true
    }
    
    func changeProgress(gesture: UIPanGestureRecognizer) {
        if (gesture.state != .Ended) {
            player?.pause();
        } else {
            player?.play();
        }
        
        var xTranslation = gesture.locationInView(self).x
        var cellWidth = bounds.width
        
        progress = Double(xTranslation/cellWidth)
        player?.progress = progress
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: self.bounds.size.width * CGFloat(progress), height: self.bounds.size.height))
    }
    
    func cellPressed(sender: UITapGestureRecognizer) {
        if let player = player {
            if (player.isPlaying()) {
                let tapPoint = sender.locationInView(self)
                let hitView = contentView.hitTest(tapPoint, withEvent: nil)
                
                if hitView == avatarImageView || hitView == profileNameLabel {
                    player.pause()
                } else {
                    player.pause()
                }
            } else { // Player is paused
                player.play()
            }
        } else {
            if let callBack = callBack {
                callBack(isPlaying: false, sender: self)
                
                if let player = player {
                    cellPressed(sender);
                }
            }
        }
    }
    
    override func prepareForReuse() {
        if let player = player {
            callBack?(isPlaying: player.isPlaying(), sender: self)
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.progressGestureRecognizer {
            if let player = player {
                var superview = self.superview as UIScrollView
                var translation = self.progressGestureRecognizer?.translationInView(self)
                
                if let translation = translation {
                    return ((fabs(translation.x) / fabs(translation.y) > 1) &&
                        (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0)) &&
                        player.isPlaying()
                }
            }
            
            return false
        }
        return true
    }
}
