//
//  Player.swift
//  Tempo
//
//  Created by Alexander Zielenski on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import AVFoundation

class Player: NSObject, AVAudioPlayerDelegate {
	
	private var currentTask: NSURLSessionDataTask?
	private static var currentPlayer: Player? {
		didSet {
			if Player.currentPlayer != oldValue {
				oldValue?.pause()
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
	private(set) var wasPlayed = false
	private(set) var finishedPlaying = false
	var delegate: PlayerDelegate!
	
    private let fileURL: NSURL
	init(fileURL: NSURL) {
		self.fileURL = fileURL
		super.init()
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
                let request = NSURLRequest(URL: fileURL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15)
				currentTask = NSURLSession.dataTaskWithCachedRequest(request) { [weak self] data, response, _ -> Void in
					guard let s = self else { return }
					if let data = data {
						s.player = try? AVAudioPlayer(data: data)
					}
					s.player?.prepareToPlay()
					s.currentTask = nil
					
					if s.shouldAutoplay {
						s.player?.play()
						// ??? PlayerDidChangeState post
					}
				}
				currentTask!.resume()
            }
        }
    }

    private var shouldAutoplay = false
	func play() {
        prepareToPlay()
        wasPlayed = true
		finishedPlaying = false
        if player == nil {
            shouldAutoplay = true
        } else {
            player?.play()
        }
    }
    
    var rate: Float {
        get {
            return player?.rate ?? 0
        }
        set {
            player?.rate = newValue
        }
    }
    
    func pause() {
        player?.pause()
        shouldAutoplay = false
    }
    
	var isPlaying: Bool {
		return player?.playing ?? false
    }
    
    func togglePlaying() {
		isPlaying ? pause() : play()
		if (isPlaying) {
			Player.currentPlayer = self
		}
    }
    
    dynamic var currentTime: NSTimeInterval {
        get {
			return player?.currentTime ?? 0
        }
        set {
			guard let player = player else { return }
			player.currentTime = max(0, min(duration, newValue))
        }
    }
    
    var duration: NSTimeInterval {
		return player?.duration ?? DBL_MAX
    }
	
	dynamic var progress: Double {
		get {
			if finishedPlaying {
				return 1
			}
			return player != nil ? currentTime / duration : 0
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
		finishedPlaying = true
		delegate.didFinishPlaying!()
    }
}
