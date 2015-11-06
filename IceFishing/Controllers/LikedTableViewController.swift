//
//  LikedTableViewController.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: PlayerTableViewController  {
    let cellIdentifier = "SongSearchTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		notifCenterSetup()
		commandCenterHandler()
		
        tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        title = "Liked"
        addHamburgerMenu()
        addRevealGesture()
        
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.frame.size.height), animated: false)
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SongSearchTableViewCell
        
        var post = posts[indexPath.row]
        if searchController.active {
            post = filteredPosts[indexPath.row]
        }
        
        cell.postView.post = post
        cell.postView.avatarImageView?.imageURL = post.song.smallArtworkURL
        
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongSearchTableViewCell
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
