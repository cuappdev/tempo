//
//  PostHistoryTableViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer

class PostHistoryTableViewController: UITableViewController, PostViewDelegate {
	
	var posts: [Post] = []
	var songLikes: [Int] = []
    var postedDates: [NSDate] = []
    var index: Int?
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
	var savedSongAlertView: SavedSongView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.iceDarkGray
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        navigationItem.title = "Post History"
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add back button to profile
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height))
        backButton.setImage(UIImage(named: "Arrow-Left"), forState: .Normal)
        backButton.addTarget(self, action: "popToPrevious", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
		
		notifCenterSetup()
		commandCenterHandler()
    }
    
    override func viewWillAppear(animated: Bool) {
		if index != nil {
			let selectedRow = NSIndexPath(forRow: index!, inSection: 0)
			self.tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
		}
    }
    
    // Return to profile view
    func popToPrevious() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		cell.postView.type = .History
		cell.postView.post = posts[indexPath.row]
		cell.postView.delegate = self
		cell.postView.post?.player.prepareToPlay()
		
        let date = NSDateFormatter.simpleDateFormatter.stringFromDate(self.postedDates[indexPath.row])
		cell.postView.dateLabel!.text = "\(date)"
		
		return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
        selectedCell.postView.backgroundColor = UIColor.iceLightGray
		currentlyPlayingIndexPath = indexPath
    }
	
	//Helper methods
	
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
	
	func didTapAddButtonForCell() {
		let screenSize = UIScreen.mainScreen().bounds
		let screenWidth = screenSize.width
		let screenHeight = screenSize.height
		savedSongAlertView = SavedSongView.instanceFromNib()
		savedSongAlertView.center = CGPointMake(screenWidth / 2, screenHeight / 2.5)
		savedSongAlertView.layer.cornerRadius = 10
		view.addSubview(savedSongAlertView)
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			UIView.animateWithDuration(0.5, animations: {
				self.savedSongAlertView.alpha = 0.0
				}, completion: { _ in
					self.savedSongAlertView.removeFromSuperview()
			})
		}
	}
}