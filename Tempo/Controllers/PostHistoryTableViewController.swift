//
//  PostHistoryTableViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer

class PostHistoryTableViewController: PlayerTableViewController {
	
	var songLikes: [Int] = []
	var postedDates: [Date] = []
	var postedDatesDict: [String: Int] = [String: Int]()
	var postedDatesSections: [String] = []
    var sectionIndex: Int?
	var rowIndex: Int?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        navigationItem.title = "Post History"
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		playingPostType = .history
		
		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = .tempoRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
		
		tableView.register(UINib(nibName: "PostHistoryHeaderSectionCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
		tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		tableView.rowHeight = 111
		tableView.sectionHeaderHeight = 33
		tableView.backgroundColor = .readCellColor
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		preparePosts()
		tableView.tableHeaderView = notConnected(true) ? nil : searchController.searchBar
		tableView.reloadData()
	}
	
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let _ = sectionIndex, let _ = rowIndex {
			let selectedRow = IndexPath(row: rowIndex!, section: sectionIndex!)
			tableView.scrollToRow(at: selectedRow, at: UITableViewScrollPosition.top, animated: true)
		}
    }
	
	fileprivate func convertDate(_ date: String) -> String {
		let dateObject = DateFormatter.slashYearMonthDayFormatter.date(from: date)
		let dateString = DateFormatter.postHistoryDateFormatter.string(from: dateObject!)

		return dateString
	}
	
	// Get the absolute index path of cell
	fileprivate func absoluteIndex(_ indexPath: IndexPath) -> Int {
		var absoluteIndex = indexPath.row
		if indexPath.section > 0 {
			for s in 0..<indexPath.section {
				absoluteIndex = absoluteIndex + postedDatesDict[postedDatesSections[s]]!
			}
		}
		return absoluteIndex
	}
	
	func relativeIndexPath(row: Int) -> IndexPath {
		var newRow = row
		var section = 0
		var s = 0
		while (newRow >= postedDatesDict[postedDatesSections[s]]!) {
			newRow -= postedDatesDict[postedDatesSections[s]]!
			section += 1
			s += 1
		}
		return IndexPath(row: newRow, section: section)
	}
	
	// Filter posted dates into dictionary of key: date, value: date_count
	func filterPostedDatesToSections(_ dates: [Date]) {
		// Clear section dictionary
		postedDatesDict = [String: Int]()
		postedDatesSections = []
		// Create new dictionary
		for d in dates {
			let date = d.yearMonthDay()
			if let count = postedDatesDict[date] {
				postedDatesDict[date] = count + 1
			} else {
				postedDatesDict[date] = 1
				postedDatesSections.append(date)
			}
		}
	}
	
    // TableView Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		cell.feedPostView.avatarImageView?.image = nil
		cell.feedPostView.type = .history
		let posts = searchController.isActive ? filteredPosts : self.posts
		let post = posts[absoluteIndex(indexPath)]
		cell.feedPostView?.post = post
		cell.feedPostView?.postViewDelegate = self
		cell.feedPostView?.playerDelegate = self
		cell.setUpPostHistoryCell()
		
		transplantPlayerAndPostViewIfNeeded(cell: cell)
		
		return cell
    }
	
	func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
		return postedDatesSections.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! PostHistoryHeaderSectionCell
		headerCell.postDate?.text = convertDate(postedDatesSections[section])
		return headerCell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return postedDatesDict[postedDatesSections[section]]!
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return convertDate(postedDatesSections[section])
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
		selectedCell.feedPostView.backgroundColor = UIColor.tempoLightGray
		currentlyPlayingIndexPath = IndexPath(row: absoluteIndex(indexPath), section: 0)
    } 
	
	func didToggleLike() {
		if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
			if let cell = tableView.cellForRow(at: relativeIndexPath(row: currentlyPlayingIndexPath.row) as IndexPath) as? FeedTableViewCell {
				cell.feedPostView.updateLikedStatus()
			}
			playerCenter.updateLikeButton()
		}
	}
	
	func didToggleAdd() {
		if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
			if let cell = tableView.cellForRow(at: currentlyPlayingIndexPath) as? FeedTableViewCell {
				cell.feedPostView.updateAddStatus()
			}
		}
	}
	
	// MARK: - Search Override
	
	override func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		if searchText == "" {
			filteredPosts = posts
		} else {
			let pred = NSPredicate(format: "song.title contains[cd] %@ OR song.artist contains[cd] %@", searchText, searchText)
			filteredPosts = (posts as NSArray).filtered(using: pred) as! [Post]
		}
		let filteredDates = filteredPosts.map { $0.date! }
		filterPostedDatesToSections(filteredDates as [Date])
		tableView.reloadData()
	}

}
