//
//  PostHistoryTableViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer

class PostHistoryTableViewController: PlayerTableViewController, PostViewDelegate {
	
	var songLikes: [Int] = []
    var postedDates: [NSDate] = []
    var index: Int?
	var savedSongAlertView: SavedSongView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.iceDarkGray
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        navigationItem.title = "Post History"
        
        addRevealGesture()
		
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
	
	func didTapAddButtonForPostView(postView: PostView) {
		savedSongAlertView = SavedSongView.instanceFromNib()
		savedSongAlertView.showSongStatusPopup(postView.songStatus, playlist: "")
	}
	
	func didLongPressOnCell(postView: PostView) {
		SpotifyController.sharedController.spotifyIsAvailable({ (success) -> Void in
			if success {
				let topVC = getTopViewController()
				let playlistVC = PlaylistTableViewController()
				let tableViewNavigationController = UINavigationController(rootViewController: playlistVC)
				
				playlistVC.song = postView.post
				topVC.presentViewController(tableViewNavigationController, animated: true, completion: nil)
			}
		})
	}
}