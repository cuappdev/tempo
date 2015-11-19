//
//  LikedTableViewController.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: PlayerTableViewController, PostViewDelegate {
    let cellIdentifier = "FeedTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		notifCenterSetup()
		commandCenterHandler()
		
        tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: "FeedCell")
        title = "Liked"
        addHamburgerMenu()
        
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        retrieveLikedSongs()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		
		var post = posts[indexPath.row]
		if searchController.active {
			post = filteredPosts[indexPath.row]
		}
		
		cell.postView.type = .Liked
		cell.postView.post = post
		cell.postView.delegate = self
		cell.postView.post?.player.prepareToPlay()
		
		return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
		cell.postView.backgroundColor = UIColor.iceLightGray
		currentlyPlayingIndexPath = indexPath
	}
	
    func retrieveLikedSongs() {
        API.sharedAPI.fetchLikes(User.currentUser.id) {
            self.posts = $0.map { Post(song: $0, user: User.currentUser) }
            self.tableView.reloadData()
        }
    }
}
