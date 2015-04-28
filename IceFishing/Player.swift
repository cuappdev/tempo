//
//  Player.swift
//  experience
//
//  Created by Alexander Zielenski on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import AVFoundation

let PlayerDidChangeStateNotification = "PlayerDidChangeState"

class Player: NSObject {
    private var player: AVPlayer? {
        didSet {
            oldValue?.pause()
            
            if let notificationValue: AnyObject = notificationValue {
                NSNotificationCenter.defaultCenter().removeObserver(notificationValue)
            }
            
            notificationValue = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification,
                object: player?.currentItem,
                queue: nil) { [weak self] (notif) -> Void in
                    self?.pause(true)
                    self?.finishedPlaying = true
                    // we finished playing, destroy the object
                    self?.destroy()
            }
        }
    }
    private var notificationValue: AnyObject?
    private(set) var finishedPlaying = false
    
    var fileURL: NSURL!
    init(fileURL: NSURL) {
        super.init()
        // hack to enable did set
        self.fileURL = fileURL
    }
    
    class func keyPathsForValuesAffectingCurrentTime(key: NSString) -> NSSet {
        return NSSet(objects: "player.currentTime")
    }
    
    class func keyPathsForValuesAffectingProgress() -> NSSet {
        return NSSet(objects: "currentTime")
    }
    
    func prepareToPlay() {
        if (self.player == nil) {
            player = AVPlayer(URL: self.fileURL)
        }
    }
    
    func destroy() {
        NSNotificationCenter.defaultCenter().removeObserver(notificationValue)
        notificationValue = nil
        self.player = nil
    }
    
    func deinit() {
        NSNotificationCenter.defaultCenter().removeObserver(notificationValue)
        notificationValue = nil
    }
    
    func play(notify: Bool) {
        prepareToPlay()
        
        if (finishedPlaying) {
            finishedPlaying = false
            currentTime = 0.0
        }
        
        player?.play()
        
        if notify {
            NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
        }
    }
    
    func pause(notify: Bool) {
        player?.pause()
        
        if notify {
            NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.rate > 0.0
        }
        return false
    }
    
    func togglePlaying() {
        if (self.isPlaying()) {
            self.pause(true)
        } else {
            self.play(true)
        }
    }
    
    dynamic var currentTime: NSTimeInterval {
        get {
            if let player = player {
                return CMTimeGetSeconds(player.currentTime())
            } else {
                return 0.0
            }
        }
        
        set {
            if let player = player {
                player.seekToTime(CMTimeMake(Int64(newValue), 1))
            }
        }
    }
    
    var duration: NSTimeInterval {
        if let player = player {
            if let item = player.currentItem {
                return CMTimeGetSeconds(item.duration)
            }
        }
        
        return DBL_MAX
    }
    
    dynamic var progress: Double {
        get {
            if finishedPlaying {
                return 1.0
            }
            
            if let player = player {
                if let item = player.currentItem {
                    return CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(item.duration)
                }
            }
            return 0.0
        }
        
        set {
            if let player = player {
                let secs = CMTimeGetSeconds(player.currentItem.duration)
                if (newValue.isNormal && secs.isNormal) {
                    finishedPlaying = newValue == 1.0
                    player.seekToTime(CMTimeMakeWithSeconds(Float64(newValue * secs), 1))
                }
            }
        }
    }
    
}
