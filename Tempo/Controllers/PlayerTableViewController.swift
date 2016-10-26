//
//  PlayerTableViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import Haneke
import MediaPlayer

class PlayerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
	
	var tableView: UITableView!
	var refreshControl: UIRefreshControl!
	var searchController: UISearchController!
	var posts: [Post] = []
	var filteredPosts: [Post] = []
    var currentlyPlayingPost: Post?
	
    var currentlyPlayingIndexPath: NSIndexPath? {
        didSet {
			if justOpened {
				removeCommandCenterHandler()
				commandCenterHandler()
				justOpened = false
			}
			var array = posts
			if searchController.active {
				array = filteredPosts
			}
            if let row = currentlyPlayingIndexPath?.row where currentlyPlayingPost?.isEqual(array[row]) ?? false {
                currentlyPlayingPost?.player.togglePlaying()
				updatePlayerCell(row)
            } else {
                currentlyPlayingPost?.player.pause(true)
				
				currentlyPlayingPost?.player.progress = 0
                if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
                    currentlyPlayingPost = array[currentlyPlayingIndexPath.row]
                    currentlyPlayingPost!.player.play(true)
					updatePlayerCell(currentlyPlayingIndexPath.row)
                } else {
                    currentlyPlayingPost = nil
                }
            }
            tableView.selectRowAtIndexPath(currentlyPlayingIndexPath, animated: false, scrollPosition: .None)
        }
    }
	var savedSongAlertView: SavedSongView!
	var justOpened = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//TableView
		tableView = UITableView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - playerCellHeight), style: .Plain)
		tableView.delegate = self
		tableView.dataSource = self
		
		//Search Bar
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		searchController.searchBar.setImage(UIImage(named: "search-icon"), forSearchBarIcon: .Search, state: .Normal)
		searchController.searchBar.setImage(UIImage(named: "clear-search-icon"), forSearchBarIcon: .Clear, state: .Normal)
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
		textFieldInsideSearchBar?.backgroundColor = UIColor.tempoDarkRed
		textFieldInsideSearchBar?.font = UIFont(name: "Avenir-Book", size: 14)
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.valueForKey("placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = UIColor.tempoUltraLightRed
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		tableView.tableHeaderView = searchController.searchBar
		tableView.backgroundView = UIView() // Fix color above search bar
		self.view.addSubview(tableView)
		
		notifCenterSetup()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		addRevealGesture()
		justOpened = true
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		removeRevealGesture()
	}
	
    // MARK: - Table view data source
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.active {
			return filteredPosts.count
		} else {
			return posts.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		preconditionFailure("This method must be overridden")
	}
	
	func navigateToSuggestions() {
		let usersVC = (UIApplication.sharedApplication().delegate as! AppDelegate).usersVC
		navigationController?.setViewControllers([usersVC], animated: false)
	}
	
    private func updateNowPlayingInfo() {
        let session = AVAudioSession.sharedInstance()
        
		guard let post = currentlyPlayingPost else { return }
		
		let center = MPNowPlayingInfoCenter.defaultCenter()
		if !post.player.finishedPlaying {
			_ = try? session.setCategory(AVAudioSessionCategoryPlayback)
			_ = try? session.setActive(true)
			
			UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
			
			let artwork = post.song.fetchArtwork() ?? UIImage(named: "temp-user")!
			var count = posts.count
			if searchController.active {
				count = filteredPosts.count
			}
			
			center.nowPlayingInfo = [
				MPMediaItemPropertyTitle: post.song.title,
				MPMediaItemPropertyArtist: post.song.artist,
				MPMediaItemPropertyAlbumTitle: post.song.album,
				MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artwork),
				MPMediaItemPropertyPlaybackDuration: post.player.duration,
				MPNowPlayingInfoPropertyElapsedPlaybackTime: post.player.currentTime,
				MPNowPlayingInfoPropertyPlaybackRate: post.player.isPlaying ? post.player.rate : 0,
				MPNowPlayingInfoPropertyPlaybackQueueIndex: currentlyPlayingIndexPath!.row,
				MPNowPlayingInfoPropertyPlaybackQueueCount: count ]
		} else {
			UIApplication.sharedApplication().endReceivingRemoteControlEvents()
			_ = try? session.setActive(false)
			center.nowPlayingInfo = nil
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
			var count = self!.posts.count
			if self!.searchController.active {
				count = self!.filteredPosts.count
			}
            if let path = self?.currentlyPlayingIndexPath {
                if path.row < count - 1 {
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
	
	func removeCommandCenterHandler() {
		let center = MPRemoteCommandCenter.sharedCommandCenter()
		center.playCommand.removeTarget(nil)
		center.pauseCommand.removeTarget(nil)
		center.nextTrackCommand.removeTarget(nil)
		center.previousTrackCommand.removeTarget(nil)
	}
	
	// MARK: - Search Stuff
	
	func filterContentForSearchText(searchText: String, scope: String = "All") {
		if searchText == "" {
			filteredPosts = posts
		} else {
			let pred = NSPredicate(format: "song.title contains[cd] %@ OR song.artist contains[cd] %@", searchText, searchText)
			filteredPosts = (posts as NSArray).filteredArrayUsingPredicate(pred) as! [Post]
		}
		tableView.reloadData()
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	//This allows for the text not to be viewed behind the search bar at the top of the screen
	private let statusBarView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20))
		view.backgroundColor = UIColor.tempoLightRed
		return view
	}()
	
	func willPresentSearchController(searchController: UISearchController) {
		navigationController?.view.addSubview(statusBarView)
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}
	
	// MARK: - Save song button clicked
	
	func didTapAddButtonForPostView(postView: PostView) {
		savedSongAlertView = SavedSongView.instanceFromNib()
		savedSongAlertView.showSongStatusPopup(postView.songStatus, playlist: "")
	}
	
	func didLongPressOnCell(postView: PostView) {
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				let topVC = getTopViewController()
				let playlistVC = PlaylistTableViewController()
				let tableViewNavigationController = UINavigationController(rootViewController: playlistVC)
				
				playlistVC.song = postView.post
				topVC.presentViewController(tableViewNavigationController, animated: true, completion: nil)
			}
		}
	}
	
	func updatePlayerCell(row: Int) {
		let playerNav = navigationController as! PlayerNavigationController
		playerNav.playerCell.post = currentlyPlayingPost
		playerNav.playerCell.postsRef = posts
		playerNav.playerCell.postRefIndex = row
	}
}