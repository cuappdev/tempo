//
//  LikedTableViewController.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: UITableViewController  {
	
	var results: [Post] = []
	let cellIdentifier = "FeedTableViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        title = "Liked"
		
		addHamburgerMenu()
        addRevealGesture()
	}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        retrieveLikedSongs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedTableViewCell
		let post = results[indexPath.row]
		cell.postView.type = .History
		cell.postView.post = post
		cell.postView.avatarImageView?.imageURL = post.song.smallArtworkURL
		
		return cell
    }
	
	func retrieveLikedSongs() {
		API.sharedAPI.fetchLikes(User.currentUser.id) {
			self.results = $0.map { Post(song: $0, user: User.currentUser) }
			self.tableView.reloadData()
		}
	}
}
