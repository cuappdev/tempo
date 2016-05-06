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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post History"
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.tempoLightRed
		tableView.addSubview(topView)
		
		tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")

		pinView.postView.type = .History
    }
    
    override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if index != nil {
			let selectedRow = NSIndexPath(forRow: index!, inSection: 0)
			tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
		}
		
		notConnected()
    }
	
    // TableView Methods
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		
		cell.postView.type = .History
		let posts = searchController.active ? filteredPosts : self.posts
		cell.postView.post = posts[indexPath.row]
		cell.postView.delegate = self
		cell.postView.post?.player.prepareToPlay()
		
        let date = NSDateFormatter.simpleDateFormatter.stringFromDate(postedDates[indexPath.row])
		cell.postView.dateLabel!.text = "\(date)"
		
		return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
        selectedCell.postView.backgroundColor = UIColor.iceLightGray
		currentlyPlayingIndexPath = indexPath
    }

}