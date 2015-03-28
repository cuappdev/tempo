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
    var player: Player! {
        didSet {
            player.callBack = {
                [unowned self]
                (isPlaying) in
                
                if (isPlaying) {
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
                } else {
                    self.timer?.invalidate()
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    dynamic private func timerFired(timer: NSTimer) {
        setNeedsDisplay()
    }
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        
        progressGestureRecognizer = UIPanGestureRecognizer(target: self, action: "changeProgress:")
        progressGestureRecognizer?.delegate = self
        addGestureRecognizer(progressGestureRecognizer!)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "cellPressed:")
        addGestureRecognizer(tapRecognizer)
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width/2
        avatarImageView.clipsToBounds = true
        
        avatarImageView.userInteractionEnabled = true
        profileNameLabel.userInteractionEnabled = true
    }
    
    func changeProgress(gesture: UIPanGestureRecognizer) {
        
        var xTranslation = gesture.locationInView(self).x
        var cellWidth = bounds.width
        
        player.progress = Double(xTranslation/cellWidth)
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        fillColor.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: self.bounds.size.width * CGFloat(player.progress), height: self.bounds.size.height))
    }
    
    func cellPressed(sender: UITapGestureRecognizer) {
        if(player.isPlaying()) {
            let tapPoint = sender.locationInView(self)
            let hitView = contentView.hitTest(tapPoint, withEvent: nil)
            
            if hitView == avatarImageView || hitView == profileNameLabel {
                println("GO TO PROFILE")
                player.pause()
            } else {
                player.pause()
            }
        } else { // Player is paused
            player.play()
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.progressGestureRecognizer {
            var superview = self.superview as UIScrollView
            var translation = self.progressGestureRecognizer?.translationInView(self)
            
            if let translation = translation {
                return ((fabs(translation.x) / fabs(translation.y) > 1) && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0))
            }
            return false
        }
        return true
    }
}
