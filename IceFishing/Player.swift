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
let PlayerDidSeekNotification = "PlayerDidSeek"
let PlayerDidFinishPlayingNotification = "PlayerDidFinishPlaying"

class Player: NSObject, AVAudioPlayerDelegate {
    var downloadCallback: ((progress: Double) -> ())?
    
    private var currentConnection: NSURLConnection?
    private var player: AVAudioPlayer? {
        didSet {
            oldValue?.pause()
            if let oldDelegate = oldValue?.delegate as? Player {
                if (self == oldDelegate) {
                    oldValue?.delegate = nil
                }
            }
            player?.delegate = self
        }
    }
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
        if (player == nil) {
            if (fileURL.fileURL) {
                player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
            } else if (currentConnection == nil) {
                // get cached data
                let request = NSURLRequest(URL: fileURL,
                    cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad,
                    timeoutInterval: 15.0)
                currentConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
            }
        }
    }
    
    func destroy() {
        self.player = nil
        NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
    }
    
    private var shouldAutoplay = false
    func play(notify: Bool) {
        prepareToPlay()
        finishedPlaying = false
        if (player == nil) {
            shouldAutoplay = true
        } else {
            player?.play()
        }
        
        if notify {
            NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
        }
    }
    
    var rate:Float {
        get {
            return player?.rate ?? 0.0
        }
        set {
            player?.rate = newValue
        }
    }
    
    func pause(notify: Bool) {
        player?.pause()
        shouldAutoplay = false
        if notify {
            NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.playing
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
                return player.currentTime
            } else {
                return 0.0
            }
        }
        
        set {
            if let player = player {
                var val = newValue
                val = max(0, val)
                val = min(duration, val)
                
                player.currentTime = val
                NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidSeekNotification, object: self)
            }
        }
    }
    
    var duration: NSTimeInterval {
        if let player = player {
            return player.duration
        }
        
        return DBL_MAX
    }
    
    dynamic var progress: Double {
        get {
            if finishedPlaying {
                return 1.0
            }
            
            if let player = player {
                return currentTime / duration
            }
            return 0.0
        }
        
        set {
            if let player = player {
                if newValue == 1.0 {
                    finishedPlaying = true
                }
                
                currentTime = newValue * duration
            }
        }
    }
    
    // MARK: NSURLConnectionDelegate
    private var expectedLength: Int64 = 0
    private var totalData: NSMutableData?
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        expectedLength = response.expectedContentLength
        totalData = NSMutableData(capacity: Int(expectedLength))
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        totalData?.appendData(data)
        if let totalData = totalData {
            downloadCallback?(progress: Double(totalData.length) / Double(expectedLength))
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        downloadCallback?(progress: 1.0)
        player = AVAudioPlayer(data: totalData, error: nil)
        totalData = nil
        currentConnection = nil
        
        if (shouldAutoplay == true) {
            player?.play()
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        pause(true)
        finishedPlaying = true
        NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidFinishPlayingNotification, object: self)
        // we finished playing, destroy the object
        destroy()
    }
}
