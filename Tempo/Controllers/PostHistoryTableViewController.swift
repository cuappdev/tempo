//
//  PostHistoryTableViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer

class PostHistoryTableViewController: PlayerTableViewController, PostViewDelegate {
	
	var songLikes: [Int] = []
    var postedDates: [NSDate] = []
    var sectionIndex: Int?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post History"
		currentPlayerVC = .PostHistory
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.tempoLightRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
		
		tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		tableView.registerNib(UINib(nibName: "PostHistoryHeaderSectionCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
		tableView.rowHeight = 80
		tableView.sectionHeaderHeight = 30
		tableView.showsVerticalScrollIndicator = false

		pinView.postView.type = .History
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.tableHeaderView = notConnected(true) ? nil : searchController.searchBar
	}
    
    override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if sectionIndex != nil {
			let selectedRow = NSIndexPath(forRow: 0, inSection: sectionIndex!)
			tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
		}
    }
	
	private func convertDate(date: String) -> String {
		let year = date.substringToIndex(date.startIndex.advancedBy(4))
		let monthDay = date.substringFromIndex(date.startIndex.advancedBy(5))
		let editedDate = monthDay + "/" + year.substringFromIndex(year.startIndex.advancedBy(2))
		let d = editedDate.stringByReplacingOccurrencesOfString("/", withString: ".")
		return d
	}
	
	// Get the absolute index path of cell
	private func absoluteIndex(indexPath: NSIndexPath) -> Int {
		var absoluteIndex = indexPath.row
		if indexPath.section > 0 {
			for s in 0...indexPath.section-1 {
				absoluteIndex = absoluteIndex + postedDatesDict![postedDatesSections![s]]!
			}
		}
		return absoluteIndex
	}
	
    // TableView Methods

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		
		cell.postView.type = .History
		let posts = searchController.active ? filteredPosts : self.posts
		cell.postView.post = posts[absoluteIndex(indexPath)]
		cell.postView.delegate = self
		cell.postView.post?.player.prepareToPlay()
		
//        let date = convertDate(postedDatesSections[indexPath.section])
	    cell.postView.dateLabel!.text = ""
		
		return cell
    }
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return postedDatesSections!.count
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! PostHistoryHeaderSectionCell
		headerCell.postDate?.text = convertDate(postedDatesSections![section])
		return headerCell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return postedDatesDict![postedDatesSections![section]]!
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return convertDate(postedDatesSections![section])
	}
	
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
        selectedCell.postView.backgroundColor = UIColor.tempoLightGray
		currentlyPlayingIndexPath = NSIndexPath(forRow: absoluteIndex(indexPath), inSection: 0)
    }

}