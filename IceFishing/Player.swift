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
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Player.changeCurrentPlayer), name: PlayerDidChangeStateNotification, object: nil)
    }
	
	func changeCurrentPlayer() {
		if self.isPlaying {
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
				currentTask = NSURLSession.dataTaskWithCachedRequest(request) { [weak self] data, response, _ -> Void in
					guard let s = self else { return }
					if let data = data {
						s.player = try? AVAudioPlayer(data: data)
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
    
    var rate: Float {
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
    
	var isPlaying: Bool {
		return player?.playing ?? false
    }
    
    func togglePlaying() {
		isPlaying ? pause(true) : play(true)
    }
    
    dynamic var currentTime: NSTimeInterval {
        get {
			return player?.currentTime ?? 0.0
        }
        set {
			guard let player = player else { return }
			player.currentTime = max(0, min(duration, newValue))
			NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidSeekNotification, object: self)
        }
    }
    
    var duration: NSTimeInterval {
		return player?.duration ?? DBL_MAX
    }
    
    dynamic var progress: Double {
        get {
            if finishedPlaying {
                return 1.0
            }
			return player != nil ? currentTime / duration : 0.0
        }
        set {
			if player == nil { return }
			if newValue == 1.0 {
				finishedPlaying = true
			}
			
			currentTime = newValue * duration
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
	
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        pause(true)
        finishedPlaying = true
        NSNotificationCenter.defaultCenter().postNotificationName(PlayerDidFinishPlayingNotification, object: self)
    }
}
