//
//  LikedTableViewController.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {
	
	var results: [Post] = []
	var filteredResults: [Post] = []
	
	private var searchController: UISearchController!
	
	let cellIdentifier = "SongSearchTableViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        title = "Liked"
		addHamburgerMenu()
		addRevealGesture()
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.dimsBackgroundDuringPresentation = false
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		
		//Formating for search Bar
		searchController.searchBar.sizeToFit()
		searchController.searchBar.delegate = self
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
		
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.active {
			return filteredResults.count
		} else {
			return results.count
		}
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SongSearchTableViewCell
		
		var post = results[indexPath.row]
		if searchController.active {
			post = filteredResults[indexPath.row]
		}
		
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
	
	private func filterContentForSearchText(searchText: String, scope: String = "All") {
		if searchText == "" {
			filteredResults = results
		} else {
			let pred = NSPredicate(format: "song.title contains[cd] %@ OR song.artist contains[cd] %@", searchText, searchText)
			filteredResults = (results as NSArray).filteredArrayUsingPredicate(pred) as! [Post]
		}
		tableView.reloadData()
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	//This allows for the text not to be viewed behind the search bar at the top of the screen
	private let statusBarView: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20))
		view.backgroundColor = UIColor.iceDarkRed
		return view
	}()
	
	func willPresentSearchController(searchController: UISearchController) {
			self.navigationController?.view.addSubview(self.statusBarView)
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		statusBarView.removeFromSuperview()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
