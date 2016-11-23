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
	
	fileprivate var currentTask: URLSessionDataTask?
	fileprivate static var currentPlayer: Player? {
		didSet {
			if Player.currentPlayer != oldValue {
				oldValue?.pause()
			}
		}
	}
    fileprivate var player: AVAudioPlayer? {
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
	
	var wasPlayed = false
	var finishedPlaying = false
	
	var delegate: PlayerDelegate!
	
    fileprivate let fileURL: URL
	init(fileURL: URL) {
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
            if fileURL.isFileURL {
				player = try? AVAudioPlayer(contentsOf: fileURL)
                player?.prepareToPlay()
            } else if currentTask == nil {
                let request = URLRequest(url: fileURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
				currentTask = URLSession.dataTaskWithCachedRequest(request) { [weak self] data, response, _ -> Void in
					guard let s = self else { return }
					if let data = data {
						s.player = try? AVAudioPlayer(data: data)
					}
					s.player?.prepareToPlay()
					s.currentTask = nil
					
					if s.shouldAutoplay {
						s.player?.play()
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
		return player?.isPlaying ?? false
    }
    
    func togglePlaying() {
		isPlaying ? pause() : play()
		if (isPlaying) {
			Player.currentPlayer = self
		}
    }
    
    dynamic var currentTime: TimeInterval {
        get {
			return player?.currentTime ?? 0
        }
        set {
			guard let player = player else { return }
			player.currentTime = max(0, min(duration, newValue))
        }
    }
    
    var duration: TimeInterval {
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
	
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		finishedPlaying = true
		delegate.didFinishPlaying!()
    }
}
