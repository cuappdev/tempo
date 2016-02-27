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
		
		title = "Liked"
		view.backgroundColor = UIColor.iceDarkGray
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		notifCenterSetup()
		commandCenterHandler()
		addHamburgerMenu()

		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.iceDarkRed
		tableView.addSubview(topView)
		
		pinView.postView.type = .Liked
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        retrieveLikedSongs()
		
		notConnected()
    }
	
    // MARK: - Table View Methods
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if posts.count > 0 {
			self.tableView.backgroundView = nil
			return 1
		} else {
			let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
			let imageView = UIImageView(image: UIImage(named: "likedThumb"))
			imageView.frame.origin = CGPoint(x: emptyView.bounds.width/2 - imageView.bounds.width/2, y: emptyView.bounds.height/2 - imageView.bounds.height/2)
			emptyView.addSubview(imageView)
			
			let label = UILabel(frame: CGRect(x: 0, y: imageView.bounds.height + 10, width: self.view.bounds.width, height: self.view.bounds.height))
			label.text = "Like songs on your home feed\nto view them here!"
			label.textColor = UIColor.whiteColor()
			label.textAlignment = .Center
			label.numberOfLines = 2
			label.font = UIFont(name: "AvenirNext-Regular", size: 16)
			emptyView.addSubview(label)
			
			self.tableView.backgroundView = emptyView
		}
		
		return 0
	}

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		
		cell.postView.type = .Liked
		let posts = searchController.active ? filteredPosts : self.posts
		cell.postView.post = posts[indexPath.row]
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