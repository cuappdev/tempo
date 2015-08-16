//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit
import MediaPlayer

class FeedViewController: UITableViewController, SongSearchDelegate {
	
	var posts: [Post] = []
	var customRefresh:ADRefreshControl!
	var plusButton: UIButton!
	
	lazy var songSearchTableViewController: SongSearchViewController = {
		let vc = SongSearchViewController(nibName: "SongSearchViewController", bundle: nil)
		vc.delegate = self
		return vc
	}()
	
	var currentlyPlayingIndexPath: NSIndexPath? {
		didSet {
			if currentlyPlayingIndexPath?.isEqual(oldValue) ?? false { // Same index path tapped
				currentlyPlayingPost?.player.togglePlaying()
			} else { // Different cell tapped
				currentlyPlayingPost?.player.pause(true)
				currentlyPlayingPost?.player.progress = 1.0 // Fill cell as played
				
				if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
					currentlyPlayingPost = posts[currentlyPlayingIndexPath.row]
					currentlyPlayingPost!.player.play(true)
				} else {
					currentlyPlayingPost = nil
				}
			}
			tableView.selectRowAtIndexPath(currentlyPlayingIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
			cellPin()
		}
	}
	var currentlyPlayingPost: Post?
	
	var topPinViewContainer: UIView = UIView()
	var bottomPinViewContainer: UIView = UIView()
	@IBOutlet var pinView: PostView!
	var pinViewGestureRecognizer: UITapGestureRecognizer!
	var lastContentOffset: CGFloat!  //Deals with pinView detection
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
			if note.object as? Player == self?.currentlyPlayingPost?.player {
				self?.updateNowPlayingInfo()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidSeekNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
			if note.object as? Player == self?.currentlyPlayingPost?.player {
				self?.updateNowPlayingInfo()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(SongDidDownloadArtworkNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
			if note.object as? Song == self?.currentlyPlayingPost?.song {
				self?.updateNowPlayingInfo()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
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
		
		// TODO: fetch the largest artwork image for lockscreen in Post
		let center = MPRemoteCommandCenter.sharedCommandCenter()
		center.playCommand.addTargetWithHandler { [weak self] _ -> MPRemoteCommandHandlerStatus in
			if let player = self?.currentlyPlayingPost?.player {
				player.play(true)
				return .Success
			}
			return .NoSuchContent
		}
		
		center.pauseCommand.addTargetWithHandler { [weak self] _ -> MPRemoteCommandHandlerStatus in
			if let player = self?.currentlyPlayingPost?.player {
				player.pause(true)
				return .Success
			}
			return .NoSuchContent
		}
		
		center.nextTrackCommand.addTargetWithHandler { [weak self] _ -> MPRemoteCommandHandlerStatus in
			if let path = self?.currentlyPlayingIndexPath {
				if path.row < self!.posts.count - 1 {
					self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row + 1, inSection: path.section)
					return .Success
				}
			}
			return .NoSuchContent
		}
		
		center.previousTrackCommand.addTargetWithHandler { [weak self] _ -> MPRemoteCommandHandlerStatus in
			if let path = self?.currentlyPlayingIndexPath {
				if path.row > 0 {
					self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row - 1, inSection: path.section)
				}
				return .Success
			}
			return .NoSuchContent
		}
		
		center.seekForwardCommand.addTargetWithHandler { _ -> MPRemoteCommandHandlerStatus in
			return .Success
		}
		
		center.seekBackwardCommand.addTargetWithHandler { _ -> MPRemoteCommandHandlerStatus in
			return .Success
		}
		
		
		//—————————————from MAIN VC——————————————————
		title = "Feed"
		beginIceFishing()
		setupAddButton()
		refreshControl = UIRefreshControl()
		customRefresh = ADRefreshControl(refreshControl: refreshControl!, tableView: self.tableView)
		refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
		
		tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		refreshFeed()
		
		pinViewGestureRecognizer = UITapGestureRecognizer(target: self, action: "togglePlay")
		pinViewGestureRecognizer.delegate = pinView
		lastContentOffset = tableView.contentOffset.y
		pinView.backgroundColor = UIColor.iceLightGray
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		rotatePlusButton(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		topPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
		topPinViewContainer.center = CGPoint(x: view.center.x, y: navigationController!.navigationBar.frame.maxY + topPinViewContainer.frame.height/2)
		view.superview!.addSubview(topPinViewContainer)
		bottomPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
		bottomPinViewContainer.center = CGPoint(x: view.center.x, y: view.frame.height - topPinViewContainer.frame.height/2)
		view.superview!.addSubview(bottomPinViewContainer)
		
		topPinViewContainer.hidden = true
		bottomPinViewContainer.hidden = true
		
		pinView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
		
		if let indexPaths = tableView.indexPathsForVisibleRows {
			tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
		}
	}
	
	// MARK: - UIRefreshControl
	
	func refreshFeed() {
		API.sharedAPI.fetchFeedOfEveryone { [weak self] in
			self?.posts = $0
			self?.tableView.reloadData()
			
			let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
			dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
				// When done requesting/reloading/processing invoke endRefreshing, to close the control
				self!.refreshControl!.endRefreshing()
			}
			
		}
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		cell.postView.post = posts[indexPath.row]
		cell.postView.post?.player.prepareToPlay()
		return cell
	}
	
	// MARK: - UITableViewDelegate
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		currentlyPlayingIndexPath = indexPath
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		let lastCell = NSIndexPath(forRow: posts.count-1, inSection: 0)
		
		if let playingIndexPath = currentlyPlayingIndexPath {
			if tableView.indexPathsForVisibleRows != nil {
				if let cellSelected = tableView.cellForRowAtIndexPath(playingIndexPath) {
					let offsetY = tableView.contentOffset.y
					if lastCell == playingIndexPath && cellSelected.frame.maxY - offsetY < parentViewController!.view.frame.height {
						if offsetY > lastContentOffset {
							bottomPinViewContainer.hidden = true
						}
					}
				}
			}
		}
		lastContentOffset = tableView.contentOffset.y
		customRefresh.scrollViewDidScroll(scrollView)
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
				} catch _ {
				}
				center.nowPlayingInfo = nil
			}
		}
	}
	
	func togglePlay() {
		pinView.post?.player.togglePlaying()
	}

	func cellPin() {
		if let selectedRow = currentlyPlayingIndexPath { //If a row is selected
			if let rowsICanSee = tableView.indexPathsForVisibleRows { //Rows Seen
				if let cellSelected = tableView.cellForRowAtIndexPath(selectedRow) as? FeedTableViewCell {
					if cellSelected.frame.minY - tableView.contentOffset.y < navigationController!.navigationBar.frame.maxY || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
						if cellSelected.frame.minY - tableView.contentOffset.y < navigationController!.navigationBar.frame.maxY {
							pinView.post = posts[selectedRow.row]
							pinView.layoutIfNeeded()
							topPinViewContainer.addSubview(pinView)
							pinView.addGestureRecognizer(pinViewGestureRecognizer)
							topPinViewContainer.hidden = false
							
						} else if cellSelected.frame.maxY - tableView.contentOffset.y > parentViewController!.view.frame.height {
							pinView.post = posts[selectedRow.row]
							pinView.layoutIfNeeded()
							bottomPinViewContainer.addSubview(pinView)
							pinView.addGestureRecognizer(pinViewGestureRecognizer)
							bottomPinViewContainer.hidden = false
						}
					}
					else {
						if selectedRow.compare(rowsICanSee.first!) != selectedRow.compare(rowsICanSee.last!) { //If they're equal then the thing is not on screen
							topPinViewContainer.hidden = true
							bottomPinViewContainer.hidden = true
							pinView.post = nil
							pinView.removeFromSuperview()
						}
					}
				}
			}
		}
	}
	
	func setupAddButton() {
		let image = UIImage(named: "Add-Icon")!
		plusButton = UIButton(type: .Custom)
		plusButton.frame = CGRectMake(0, 0, image.size.width, image.size.height)
		plusButton.setImage(image, forState: .Normal)
		plusButton.imageView!.contentMode = .Center
		plusButton.imageView!.clipsToBounds = false
		plusButton.adjustsImageWhenHighlighted = false
		plusButton.addTarget(self, action: "plusButtonTapped", forControlEvents: .TouchUpInside)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
	}
	
	func rotatePlusButton(active: Bool) {
		if let currentTransform = (self.plusButton.imageView!.layer.presentationLayer() as? CALayer)?.transform {
			self.plusButton.imageView?.layer.transform = currentTransform
		}
		plusButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
		plusButton.addTarget(active ? songSearchTableViewController : self, action: active ? "dismiss" : "plusButtonTapped", forControlEvents: .TouchUpInside)
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			let transform = active ? CGAffineTransformMakeRotation(CGFloat(M_PI_4)) : CGAffineTransformIdentity
			self.plusButton.imageView!.transform = transform
			}, completion: nil)
	}
	
	func plusButtonTapped() {
		rotatePlusButton(true)
		
		songSearchTableViewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		songSearchTableViewController.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
		navigationController?.pushViewController(songSearchTableViewController, animated: false)
	}
	
	// MARK: - SongSearchDelegate
	
	func didSelectSong(song: Song) {
		posts.insert(Post(song: song, user: User.currentUser, date: NSDate(), likes: 0), atIndex: 0)
		API.sharedAPI.updatePost(User.currentUser.id, song: song) { song in
			self.tableView.reloadData()
		}
	}
}
