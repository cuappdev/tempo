//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit
import MediaPlayer

class FeedViewController: UITableViewController, UIScrollViewDelegate, UISearchBarDelegate {
    
    var posts: [Post] = []
    var customRefresh:ADRefreshControl!
    
    var currentlyPlayingIndexPath: NSIndexPath? {
        didSet {
            if (currentlyPlayingIndexPath?.isEqual(oldValue) ?? false) { // Same index path tapped
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
    
    func addSong(track: Song) {
        posts.insert(Post(song: track, user: User.currentUser, date: NSDate(), likes: 0), atIndex: 0)
        API.sharedAPI.updatePost(User.currentUser.id, song: track) { song in
            self.tableView.reloadData()
        }
    }
    
    private func updateNowPlayingInfo() {
        let session = AVAudioSession.sharedInstance()
        
        if let post = self.currentlyPlayingPost {
            // state change, update play information
            let center = MPNowPlayingInfoCenter.defaultCenter()
            if (post.player.progress != 1.0) {
                session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
                session.setActive(true, error: nil)
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                
                let artwork = post.song.fetchArtwork() ?? UIImage(named: "Sexy")!
                center.nowPlayingInfo = [
                    MPMediaItemPropertyTitle:  post.song.title,
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
                session.setActive(false, error: nil)
                center.nowPlayingInfo = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidChangeStateNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
            if (note.object as? Player == self?.currentlyPlayingPost?.player) {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidSeekNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
            if (note.object as? Player == self?.currentlyPlayingPost?.player) {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(SongDidDownloadArtworkNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
            if (note.object as? Song == self?.currentlyPlayingPost?.song) {
                self?.updateNowPlayingInfo()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] (note) -> Void in
            if let current = self?.currentlyPlayingPost {
                if (current.player == note.object as? Player) {
                    let path = self!.currentlyPlayingIndexPath
                    if let path = path {
                        var row = path.row + 1
                        if (row >= self!.posts.count) {
                            row = 0
                        }
                        
                        self?.currentlyPlayingIndexPath = NSIndexPath(forRow: row, inSection: path.section)
                    }
                }
            }
        }
        
        //!TODO: fetch the largest artwork image for lockscreen in Post
        let center = MPRemoteCommandCenter.sharedCommandCenter()
        center.playCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if let player = self?.currentlyPlayingPost?.player {
                player.play(true)
                return .Success
            }
            return .NoSuchContent
        }
        center.pauseCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if let player = self?.currentlyPlayingPost?.player {
                player.pause(true)
                return .Success
            }
            return .NoSuchContent
        }
        
        center.nextTrackCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if let path = self?.currentlyPlayingIndexPath {
                if (path.row < self!.posts.count - 1) {
                    self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row + 1, inSection: path.section)
                    return .Success
                }
            }
            return .NoSuchContent
        }
        
        center.previousTrackCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if let path = self?.currentlyPlayingIndexPath {
                if (path.row > 0) {
                    self?.currentlyPlayingIndexPath = NSIndexPath(forRow: path.row - 1, inSection: path.section)
                }
                return .Success
            }

            return .NoSuchContent
        }
        
        center.seekForwardCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            
            return .Success
        }
        
        center.seekBackwardCommand.addTargetWithHandler { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            
            return .Success
        }
        
        
        //—————————————from MAIN VC——————————————————
        self.title = "Feed"
        beginIceFishing()
        initializeSearch()
        
        refreshControl = UIRefreshControl()
        customRefresh = ADRefreshControl(refreshControl: refreshControl!, tableView: self.tableView)
        refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
        //refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(NSDate())", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        refreshFeed()
        
        //background color for the view
        tableView.rowHeight = 90
        
        pinViewGestureRecognizer = UITapGestureRecognizer(target: self, action: "togglePlay")
        pinViewGestureRecognizer.delegate = pinView
        lastContentOffset = tableView.contentOffset.y
        pinView.backgroundColor = UIColor.iceLightGray()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        topPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
        topPinViewContainer.center = CGPoint(x: view.center.x, y: navigationController!.navigationBar.frame.maxY + topPinViewContainer.frame.height/2)
        parentViewController!.view.addSubview(topPinViewContainer)
        bottomPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
        bottomPinViewContainer.center = CGPoint(x: view.center.x, y: view.frame.height - topPinViewContainer.frame.height/2)
        parentViewController!.view.addSubview(bottomPinViewContainer)
        
        topPinViewContainer.hidden = true
        bottomPinViewContainer.hidden = true
        
        pinView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.rowHeight)
    }
    
    func togglePlay() {
        pinView.post?.player.togglePlaying()
    }
    
    //MARK: - UIRefreshControl
    func refreshFeed() {
        API.sharedAPI.fetchFeedOfEveryone {
            [weak self] in
            self?.posts = $0
            self?.tableView.reloadData()
            
            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)));
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
        cellPin()
        if var lastCell = NSIndexPath(forRow: posts.count-1, inSection: 0) {
            if (currentlyPlayingIndexPath != nil) {
                var rowsICanSee = tableView.indexPathsForVisibleRows() as! [NSIndexPath]
                if let cellSelected = tableView.cellForRowAtIndexPath(currentlyPlayingIndexPath!) {
                    if (lastCell == currentlyPlayingIndexPath && cellSelected.frame.maxY - tableView.contentOffset.y < parentViewController!.view.frame.height) {
                        if (tableView.contentOffset.y > lastContentOffset) {
                            bottomPinViewContainer.hidden = true
                        }
                    }
                }
            }
        }
        lastContentOffset = tableView.contentOffset.y
        customRefresh.scrollViewDidScroll(scrollView)
    }
    
    func cellPin() {
        if let selectedRow = currentlyPlayingIndexPath { //If a row is selected
            let rowsICanSee = tableView.indexPathsForVisibleRows() as! [NSIndexPath] //Rows Seen
            if let cellSelected = tableView.cellForRowAtIndexPath(selectedRow) as? FeedTableViewCell {
                if cellSelected.frame.minY - tableView.contentOffset.y < navigationController!.navigationBar.frame.maxY || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
                    if (cellSelected.frame.minY - tableView.contentOffset.y < navigationController!.navigationBar.frame.maxY) {
                        pinView.post = posts[selectedRow.row]
                        pinView.layoutIfNeeded()
                        topPinViewContainer.addSubview(pinView)
                        pinView.addGestureRecognizer(pinViewGestureRecognizer)
                        topPinViewContainer.hidden = false
                        
                    } else if (cellSelected.frame.maxY - tableView.contentOffset.y > parentViewController!.view.frame.height) {
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
    
    // From Old Main VC, might need some cleanup
    
    let kSearchResultHeight: CGFloat = 72
    var searchTableDelegateDataSource: SearchSongTableDelegateDataSource!
    var searchBanner: UIView!
    var searchContainer: UIView!
    var searchTable: SearchSongTableView!
    var searchBar: UISearchBar!
    var searchBottomView: UIView!
    var preserveTitle: String!
    var plusButton: UIButton!
    var isSearching: Bool = false
    
    // Initialize plus sign and the drop-down searchbar.
    func initializeSearch() {
        var plusContainer = UIView(frame: CGRectMake(0, 0, 44, 44))
        plusButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        plusButton.setTitle("+", forState: UIControlState.Normal)
        plusButton.titleLabel?.font = UIFont.systemFontOfSize(36)
        plusButton.titleLabel?.textColor = UIColor.whiteColor()
        plusButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 8.0, 0.0);
        plusButton.addTarget(self, action: "plusButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        plusContainer.addSubview(plusButton)
        var button = UIBarButtonItem(customView: plusContainer)
        navigationItem.rightBarButtonItem = button
        var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        spacer.width = -16;
        navigationItem.rightBarButtonItems = [spacer, button]
        
        searchContainer = UIView(frame: CGRectMake(0, 64, screenSize.width, 54))
        searchContainer.clipsToBounds = true
        searchBanner = UIView(frame: CGRectMake(0, -54, screenSize.width, 54))
        var bounds = searchBanner.bounds
        bounds.origin.y = 10
        bounds.size.height = 44
        searchBar = UISearchBar(frame: bounds)
        searchBanner.backgroundColor = UIColor(red: 180/255.0, green: 72/255.0, blue: 65/255.0, alpha: 1)
        searchBar.barTintColor = UIColor(red: 172/255.0, green: 77/255.0, blue: 70/255.0, alpha: 1)
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.barStyle = UIBarStyle.Black
        searchBar.delegate = self
        searchBanner.addSubview(searchBar)
        searchContainer.addSubview(searchBanner)
        navigationController?.view.addSubview(searchContainer)
        
        searchBottomView = UIView(frame: CGRectMake(0, screenSize.height, screenSize.width, CGFloat(kSearchResultHeight)))
        navigationController?.view.addSubview(searchBottomView)
    }
    
    func rotatePlusButton(active: Bool) {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 50, options: nil, animations: {
            if active {
                var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
                self.plusButton.transform = transform
            } else {
                var transform = CGAffineTransformIdentity
                self.plusButton.transform = transform
            }
        }, completion: nil)
    }
    
    func dropSearchBar(active: Bool) {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 20, options: nil, animations: {
            if active {
                self.searchBanner.frame.origin.y = -10
            } else {
                self.searchBanner.frame.origin.y = -54
            }
        }, completion: nil)
    }
    
    func plusButtonTapped() {
        if !isSearching {
            preserveTitle = navigationItem.title
            navigationItem.title = "Choose Your Song of the Day"
            
            var bounds = view.bounds
            bounds.origin.y = 64
            bounds.size.height = screenSize.height - 64
            searchTable = SearchSongTableView(frame: bounds, style: UITableViewStyle.Plain)
            searchTableDelegateDataSource = SearchSongTableDelegateDataSource(parent: self, table: searchTable, bottom: searchBottomView)
            searchTable.alpha = 0
            searchTable.dataSource = searchTableDelegateDataSource
            searchTable.delegate = searchTableDelegateDataSource
            searchTableDelegateDataSource.parent = self
            searchTableDelegateDataSource.tableView = searchTable
            navigationController?.view.insertSubview(searchTable, belowSubview: searchContainer)
            UIView.animateWithDuration(0.4, animations: {
                self.searchTable.alpha = 1
            })
            
            delay(0.05) {
                self.searchBar.becomeFirstResponder()
            }
        } else {
            navigationItem.title = preserveTitle
            searchBottomView.frame.origin.y = screenSize.height
            searchTableDelegateDataSource.finishSearching()
            
            searchBar.resignFirstResponder()
            searchBar.text = ""
            searchTable.removeFromSuperview()
        }
        
        isSearching = !isSearching
        rotatePlusButton(isSearching)
        dropSearchBar(isSearching)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchTableDelegateDataSource.update(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func selectSong() {
        searchBar.resignFirstResponder()
    }
    
    func submitSong(song: Song) {
        searchBar.resignFirstResponder()
        plusButtonTapped()
        addSong(song)
    }
}
