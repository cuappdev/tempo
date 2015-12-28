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
	
	private var currentTask: NSURLSessionDataTask?
	private let session: NSURLSession = {
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.requestCachePolicy = .ReturnCacheDataElseLoad
		return NSURLSession(configuration: config)
	}()
	private static var currentPlayer: Player? {
		didSet {
			if Player.currentPlayer != oldValue {
				oldValue?.pause(true)
			}
		}
	}
    private var player: AVAudioPlayer? {
        didSet {
            oldValue?.pause()
            if let oldDelegate = oldValue?.delegate as? Player {
                if self == oldDelegate {
                    oldValue?.delegate = nil
                }
            }
            player?.delegate = self
        }
    }
    private(set) var finishedPlaying = false
    
    private let fileURL: NSURL
	init(fileURL: NSURL) {
		self.fileURL = fileURL
		super.init()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeCurrentPlayer", name: PlayerDidChangeStateNotification, object: nil)
    }
	
	func changeCurrentPlayer() {
		if self.isPlaying() {
			Player.currentPlayer = self
		}
	}
    
    class func keyPathsForValuesAffectingCurrentTime(key: String) -> Set<String> {
        return Set(["player.currentTime"])
    }
    
    class func keyPathsForValuesAffectingProgress() -> Set<String> {
        return Set(["currentTime"])
    }
    
    func prepareToPlay() {
        if player == nil {
            if fileURL.fileURL {
				player = try? AVAudioPlayer(contentsOfURL: fileURL)
                player?.prepareToPlay()
            } else if currentTask == nil {
                let request = NSURLRequest(URL: fileURL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15.0)
				currentTask = session.dataTaskWithRequest(request) { [weak self] data, response, _ -> Void in
					guard let s = self else { return }
					if let data = data {
						s.player = try? AVAudioPlayer(data: data)
						if let response = response {
							let cachedResponse = NSCachedURLResponse(response: response, data: data)
							NSURLCache.sharedURLCache().storeCachedResponse(cachedResponse, forRequest: request)
						}
					}
					s.player?.prepareToPlay()
					s.currentTask = nil
					
					if s.shouldAutoplay {
						s.player?.play()
						if s.shouldNotify {
							NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
						}
					}
				}
				currentTask!.resume()
            }
        }
    }

    private var shouldAutoplay = false
    private var shouldNotify = false
    func play(notify: Bool) {
        prepareToPlay()
        finishedPlaying = false
        if player == nil {
            shouldAutoplay = true
            shouldNotify = notify
        } else {
            player?.play()
            if notify {
                NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidChangeStateNotification, object: self)
            }
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
        if isPlaying() {
            pause(true)
        } else {
            play(true)
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
            
            if let _ = player {
                return currentTime / duration
            }
            return 0.0
        }
        
        set {
            if let _ = player {
                if newValue == 1.0 {
                    finishedPlaying = true
                }
                
                currentTime = newValue * duration
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
	
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        pause(true)
        finishedPlaying = true
        NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidFinishPlayingNotification, object: self)
        // we finished playing, destroy the object
    }
}
