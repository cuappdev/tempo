//
//  PlayerTableViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import MediaPlayer

@objc protocol PlayerDelegate {
	func didTogglePlaying(animate: Bool)
	@objc optional func didFinishPlaying()
	@objc optional func didChangeProgress()
	@objc optional func didToggleLike()
	@objc optional func didToggleAdd()
	@objc optional func playNextSong()
	@objc optional func playPrevSong()
}

enum PlayingPostType {
	case feed
	case history
	case liked
}

class PlayerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, PostViewDelegate, PlayerDelegate {
	
	var tableView: UITableView!
	var refreshControl: UIRefreshControl!
	var searchController: UISearchController!
	var posts: [Post] = []
	var filteredPosts: [Post] = []
    var currentlyPlayingPost: Post?
	var playerNav: PlayerNavigationController!
	var playingPostType: PlayingPostType?
	
    var currentlyPlayingIndexPath: IndexPath? {
        didSet {
			if justOpened {
				removeCommandCenterHandler()
				commandCenterHandler()
				justOpened = false
			}
			var array = posts
			if searchController.isActive {
				array = filteredPosts
			}
            if let row = currentlyPlayingIndexPath?.row, (playerNav.currentPost?.song.equals(other: array[row].song) ?? false && self == (playerNav.playerCell.delegate as! PlayerTableViewController)) {
                didTogglePlaying(animate: true)
            } else {
				//Deal with past post that's being played
                currentlyPlayingPost?.player.pause()
				currentlyPlayingPost?.player.progress = 0
				if let oldValue = oldValue {
					if self is PostHistoryTableViewController {
						let neoSelf = self as! PostHistoryTableViewController
						if let cell = tableView.cellForRow(at: neoSelf.relativeIndexPath(row: oldValue.row) as IndexPath) as? FeedTableViewCell {
							cell.postView.updatePlayingStatus()
						}
					} else if self is LikedTableViewController {
						if let cell = tableView.cellForRow(at: oldValue) as? LikedTableViewCell {
							cell.postView?.updatePlayingStatus()
						}
					} else {
						if let cell = tableView.cellForRow(at: oldValue) as? FeedTableViewCell {
							cell.postView.updatePlayingStatus()
						}
					}
				}
				
				//update post to new song
                currentlyPlayingPost = array[currentlyPlayingIndexPath!.row]
				if self is FeedViewController {
					playingPostType = .feed
				} else if self is LikedTableViewController {
					playingPostType = .liked
				} else {
					playingPostType = .history
				}
				updatePlayerNavRefs(row: currentlyPlayingIndexPath!.row)
				didTogglePlaying(animate: true)
            }
            tableView.selectRow(at: currentlyPlayingIndexPath, animated: false, scrollPosition: .none)
        }
    }
	
	var savedSongAlertView: SavedSongView!
	var justOpened = true
	
	private var downloadArtworkNotificationHandler: NSObjectProtocol?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//TableView
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		
		playerNav = navigationController as! PlayerNavigationController
		
		//Search Bar
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		searchController.searchBar.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .search, state: UIControlState())
		searchController.searchBar.setImage(UIImage(named: "clear-search-icon"), for: .clear, state: UIControlState())
		
		let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = .white
		textFieldInsideSearchBar?.backgroundColor = .searchBackgroundRed
		textFieldInsideSearchBar?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = .searchTextColor
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		tableView.tableHeaderView = searchController.searchBar
		tableView.backgroundView = UIView() // Fix color above search bar
		self.view.addSubview(tableView)
		
		notifCenterSetup()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		justOpened = true
	}
	
    // MARK: - Table view data source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.isActive {
			return filteredPosts.count
		} else {
			return posts.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		preconditionFailure("This method must be overridden")
	}
	
	func preparePosts() {
		posts.forEach({ (post) in
			post.player.delegate = self
			post.player.prepareToPlay()
		})
	}
	
	func navigateToSuggestions() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		
		let sidebarVC = appDelegate.sidebarVC
		sidebarVC.preselectedIndex = 1
		sidebarVC.selectionHandler?(appDelegate.usersVC)
	}
	
    fileprivate func updateNowPlayingInfo() {
        let session = AVAudioSession.sharedInstance()
        
		guard let post = currentlyPlayingPost else { return }
		
		let center = MPNowPlayingInfoCenter.default()
		if !post.player.finishedPlaying {
			_ = try? session.setCategory(AVAudioSessionCategoryPlayback)
			_ = try? session.setActive(true)
			
			UIApplication.shared.beginReceivingRemoteControlEvents()
			
			let artwork = post.song.fetchArtwork() ?? UIImage()
			var count = posts.count
			if searchController.isActive {
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
			UIApplication.shared.endReceivingRemoteControlEvents()
			_ = try? session.setActive(false)
			center.nowPlayingInfo = nil
			
		}
    }
    
    func notifCenterSetup() {
        downloadArtworkNotificationHandler = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SongDidDownloadArtworkNotification), object: nil, queue: nil) { [weak self] note in
            if note.object as? Song == self?.currentlyPlayingPost?.song {
                self?.updateNowPlayingInfo()
            }
        }
    }
	
	deinit {
		if let downloadArtworkNotificationHandler = downloadArtworkNotificationHandler {
			NotificationCenter.default.removeObserver(downloadArtworkNotificationHandler)
		}
	}
	
    func commandCenterHandler() {
        // TODO: fetch the largest artwork image for lockscreen in Post
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            if let _ = self?.currentlyPlayingPost?.player {
                self?.didTogglePlaying(animate: true)
                return .success
            }
            return .noSuchContent
        }

        center.pauseCommand.addTarget { [weak self] _ in
            if let _ = self?.currentlyPlayingPost?.player {
                self?.didTogglePlaying(animate: true)
                return .success
            }
            return .noSuchContent
        }
        
        center.nextTrackCommand.addTarget (handler: { [weak self] _ in
			var count = self!.posts.count
			if self!.searchController.isActive {
				count = self!.filteredPosts.count
			}
            if let path = self?.currentlyPlayingIndexPath {
                if path.row < count - 1 {
                    self?.currentlyPlayingIndexPath = IndexPath(row: path.row + 1, section: path.section)
                    return .success
                }
            }
            return .noSuchContent
        })
        
        center.previousTrackCommand.addTarget (handler: { [weak self] _ in
            if let path = self?.currentlyPlayingIndexPath {
                if path.row > 0 {
                    self?.currentlyPlayingIndexPath = IndexPath(row: path.row - 1, section: path.section)
                }
                return .success
            }
            return .noSuchContent
        })
        
        center.seekForwardCommand.addTarget (handler: { _ in .success })
        center.seekBackwardCommand.addTarget (handler: { _ in .success })
    }
	
	func removeCommandCenterHandler() {
		let center = MPRemoteCommandCenter.shared()
		center.playCommand.removeTarget(nil)
		center.pauseCommand.removeTarget(nil)
		center.nextTrackCommand.removeTarget(nil)
		center.previousTrackCommand.removeTarget(nil)
	}
	
	// MARK: - Search Stuff
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		if searchText == "" {
			filteredPosts = posts
		} else {
			let pred = NSPredicate(format: "song.title contains[cd] %@ OR song.artist contains[cd] %@", searchText, searchText)
			filteredPosts = (posts as NSArray).filtered(using: pred) as! [Post]
		}
		tableView.reloadData()
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	//This allows for the text not to be viewed behind the search bar at the top of the screen
	fileprivate let statusBarView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
		view.backgroundColor = .tempoRed
		return view
	}()
	
	func willPresentSearchController(_ searchController: UISearchController) {
		navigationController?.view.addSubview(statusBarView)
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}
	
	// MARK: - Save song button clicked
	func didTapAddButtonForPostView(_ saved: Bool) {
		savedSongAlertView = SavedSongView.instanceFromNib()
		let songStatus: SavedSongStatus = saved ? .notSaved : .saved
		savedSongAlertView.showSongStatusPopup(songStatus, playlist: "")
	}
	
	func didLongPressOnCell(_ postView: PostView) {
		SpotifyController.sharedController.spotifyIsAvailable { success in
			if success {
				let topVC = getTopViewController()
				let playlistVC = PlaylistTableViewController()
				let tableViewNavigationController = UINavigationController(rootViewController: playlistVC)
				
				playlistVC.song = postView.post
				topVC.present(tableViewNavigationController, animated: true, completion: nil)
			}
		}
	}
	
	// MARK: - PostViewDelegate
	
	func didTogglePlaying(animate: Bool) {
		if let post = currentlyPlayingPost {
			post.player.togglePlaying()
			if animate {
				updatePlayingCells()
				updateNowPlayingInfo()
			}
		}
	}
	
	func didFinishPlaying() {
		playNextSong()
	}
	
	func playNextSong() {
		var index = currentlyPlayingIndexPath!.row + 1
		index = (index >= posts.count) ? 0 : index
		currentlyPlayingIndexPath = IndexPath(row: index, section: 0)
	}
	
	func playPrevSong() {
		var index = currentlyPlayingIndexPath!.row - 1
		index = (index < 0) ? 0 : index
		currentlyPlayingIndexPath = IndexPath(row: index, section: 0)
	}
	
	func didChangeProgress() {
		updateNowPlayingInfo()
	}
	
	// Updates all views related to some player
	func updatePlayingCells() {
		if let path = currentlyPlayingIndexPath {
			if self is PostHistoryTableViewController {
				let neoSelf = self as! PostHistoryTableViewController
				if let cell = tableView.cellForRow(at: neoSelf.relativeIndexPath(row: path.row) as IndexPath) as? FeedTableViewCell {
					cell.postView.updatePlayingStatus()
				}
			} else if self is LikedTableViewController {
				if let cell = tableView.cellForRow(at: path) as? LikedTableViewCell {
					cell.postView?.updatePlayingStatus()
				}
			} else {
				if let cell = tableView.cellForRow(at: path) as? FeedTableViewCell {
					cell.postView.updatePlayingStatus()
				}
			}
			
			playerNav.updatePlayingStatus()
		}
	}
	
	func updatePlayerNavRefs(row: Int) {
		playerNav.updateDelegates(delegate: self)
		playerNav.playingPostType = playingPostType
		playerNav.currentPost = currentlyPlayingPost
		playerNav.postsRef = posts
		playerNav.postRefIndex = row
	}
}
