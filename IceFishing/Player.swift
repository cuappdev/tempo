//
//  Player.swift
//  experience
//
//  Created by Alexander Zielenski on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import AVFoundation

class Player: NSObject {
    private var player: AVPlayer?
    var callBack: ((playing: Bool) -> Void)?
    private var notificationValue: AnyObject?
    private(set) var finishedPlaying = false
    
    var fileURL: NSURL! {
        didSet {
            if let notificationValue: AnyObject = notificationValue {
                NSNotificationCenter.defaultCenter().removeObserver(notificationValue)
            }
            
            player?.pause()
            player = AVPlayer(URL: self.fileURL)
            notificationValue = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification,
                object: player?.currentItem,
                queue: nil) { [unowned self] (notif) -> Void in
                    self.finishedPlaying = true
            }
        }
    }
    
    
    init(fileURL: NSURL) {
        super.init()
        // hack to enable did set
        setFileURL(fileURL)
    }
    
    func setFileURL(url: NSURL) {
        self.fileURL = url
    }
    
    class func keyPathsForValuesAffectingCurrentTime(key: NSString) -> NSSet {
        return NSSet(objects: "player.currentTime")
    }
    
    class func keyPathsForValuesAffectingProgress() -> NSSet {
        return NSSet(objects: "currentTime")
    }
    
    func play() {
        if (finishedPlaying) {
            finishedPlaying = false
            currentTime = 0.0
        }
        
        player?.play()
        
        if let callBack = callBack {
            callBack(playing: self.isPlaying());
        }
    }
    
    func pause() {
        player?.pause()
        
        if let callBack = callBack {
            callBack(playing: self.isPlaying());
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.rate > 0.0
        }
        return false;
    }
    
    func togglePlaying() {
        if (self.isPlaying()) {
            self.pause()
        } else {
            self.play();
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
                    finishedPlaying = false
                    player.seekToTime(CMTimeMake(Int64(newValue * secs), 1))
                }
            }
        }
    }
    
}
