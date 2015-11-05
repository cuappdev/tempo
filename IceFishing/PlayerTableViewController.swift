//
//  PlayerTableViewController.swift
//  IceFishing
//
//  Created by Jesse Chen on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerTableViewController: UITableViewController {
    var posts: [Post] = []
    var currentlyPlayingPost: Post?
    var currentlyPlayingIndexPath: NSIndexPath? {
        didSet {
            if let row = currentlyPlayingIndexPath?.row where currentlyPlayingPost?.isEqual(posts[row]) ?? false {
                currentlyPlayingPost?.player.togglePlaying()
            } else {
                currentlyPlayingPost?.player.pause(true)
                currentlyPlayingPost?.player.progress = 1.0 // Fill cell as played
                
                if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
                    currentlyPlayingPost = posts[currentlyPlayingIndexPath.row]
                    currentlyPlayingPost!.player.play(true)
                } else {
                    currentlyPlayingPost = nil
                }
            }
            tableView.selectRowAtIndexPath(currentlyPlayingIndexPath, animated: false, scrollPosition: .None)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    private func updateNowPlayingInfo() {
        let session = AVAudioSession.sharedInstance()
        
        if let post = self.currentlyPlayingPost {
            // state change, update play information
            let center = MPNowPlayingInfoCenter.defaultCenter()
            if post.player.progress != 1.0 {
                do {
                    try session.setCategory(AVAudioSessionCategoryPlayback)
                } catch _ {
                }
                do {
                    try session.setActive(true)
                } catch _ {
                }
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                
                let artwork = post.song.fetchArtwork() ?? UIImage(named: "Sexy")!
                center.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: post.song.title,
                    MPMediaItemPropertyArtist: post.song.artist,
                    MPMediaItemPropertyAlbumTitle: post.song.album,
                    MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artwork),
                    MPMediaItemPropertyPlaybackDuration: post.player.duration,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: post.player.currentTime,
                    MPNowPlayingInfoPropertyPlaybackRate: post.player.isPlaying() ? post.player.rate : 0.0,
                    MPNowPlayingInfoPropertyPlaybackQueueIndex: currentlyPlayingIndexPath!.row,
                    MPNowPlayingInfoPropertyPlaybackQueueCount: posts.count ]
            } else {
                UIApplication.sharedApplication().endReceivingRemoteControlEvents()
                do {
                    try session.setActive(false)
                } catch {
                }
                center.nowPlayingInfo = nil
            }
        }
    }
    
    func notifCenterSetup() {
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification, object: nil, queue: nil) { [weak self] note in
            if note.object as? Player == self?.currentlyPlayingPost?.player {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidSeekNotification, object: nil, queue: nil) { [weak self] note in
            if note.object as? Player == self?.currentlyPlayingPost?.player {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(SongDidDownloadArtworkNotification, object: nil, queue: nil) { [weak self] note in
            if note.object as? Song == self?.currentlyPlayingPost?.song {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] note in
            if let current = self?.currentlyPlayingPost {
                if current.player == note.object as? Player {
                    let path = self!.currentlyPlayingIndexPath
                    if let path = path {
                        var row = path.row + 1
                        if row >= self!.posts.count {
                            row = 0
                        }
                        
                        self?.currentlyPlayingIndexPath = NSIndexPath(forRow: row, inSection: path.section)
                    }
                }
            }
        }
    }
    
    func commandCenterHandler() {
        // TODO: fetch the largest artwork image for lockscreen in Post
        let center = MPRemoteCommandCenter.sharedCommandCenter()
        center.playCommand.addTargetWithHandler { [weak self] _ in
            if let player = self?.currentlyPlayingPost?.player {
                player.play(true)
                return .Success
            }
            return .NoSuchContent
        }
        
        center.pauseCommand.addTargetWithHandler { [weak self] _ in
            if let player = self?.currentlyPlayingPost?.player {
                player.pause(true)
                return .Success
            }
            return .NoSuchContent
        }
        
        center.nextTrackCommand.addTargetWithHandler { [weak self] _ in
            if let path = self?.currentlyPlayingIndexPath {
                if path.row < self!.posts.count - 1 {
                    self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row + 1, inSection: path.section)
                    return .Success
                }
            }
            return .NoSuchContent
        }
        
        center.previousTrackCommand.addTargetWithHandler { [weak self] _ in
            if let path = self?.currentlyPlayingIndexPath {
                if path.row > 0 {
                    self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row - 1, inSection: path.section)
                }
                return .Success
            }
            return .NoSuchContent
        }
        
        center.seekForwardCommand.addTargetWithHandler { _ in .Success }
        center.seekBackwardCommand.addTargetWithHandler { _ in .Success }
    }
}