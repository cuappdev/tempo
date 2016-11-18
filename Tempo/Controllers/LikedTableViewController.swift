//
//  LikedTableViewController.swift
//  Tempo
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: PlayerTableViewController {
    let cellIdentifier = "FeedTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Liked"
		view.backgroundColor = UIColor.tempoDarkGray
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		tableView.rowHeight = 100
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		addHamburgerMenu()

		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.tempoLightRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.tableHeaderView = notConnected(true) ? nil : searchController.searchBar
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
        retrieveLikedSongs()
    }
	
    // MARK: - Table View Methods
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		
		cell.postView.type = .liked
		let posts = searchController.isActive ? filteredPosts : self.posts
		cell.postView.playerCellRef = playerNav.playerCell
		cell.postView.expandedPlayerRef = playerNav.expandedCell
		cell.postView.post = posts[indexPath.row]
		cell.postView.postViewDelegate = self
		cell.postView.playerDelegate = self
		cell.postView.post?.player.delegate = self
		cell.postView.post?.player.prepareToPlay()
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
		cell.postView.backgroundColor = UIColor.tempoLightGray
		playerNav.playerCell.postsLikable = false
		playerNav.expandedCell.postsLikable = false
		playerNav.expandedCell.postHasInfo = false
		currentlyPlayingIndexPath = indexPath
	}
	
    func retrieveLikedSongs() {
		
		let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
		activityIndicatorView.center = view.center
		activityIndicatorView.startAnimating()
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			view.addSubview(activityIndicatorView)
		}
		
        API.sharedAPI.fetchLikes(User.currentUser.id) {
            self.posts = $0.map { Post(song: $0, user: User.currentUser) }
            self.tableView.reloadData()
			
			if self.posts.count == 0 {
				self.tableView.backgroundView = UIView.viewForEmptyViewController(.Liked, size: self.view.bounds.size, isCurrentUser: true, userFirstName: "")
			} else {
				self.tableView.backgroundView = nil
			}
			
			activityIndicatorView.stopAnimating()
			activityIndicatorView.removeFromSuperview()
        }
    }

}
