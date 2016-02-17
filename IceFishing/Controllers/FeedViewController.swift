//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit
import MediaPlayer

class FeedViewController: PlayerTableViewController, SongSearchDelegate, PostViewDelegate {
	
	var customRefresh: ADRefreshControl?
	var plusButton: UIButton!
	
	lazy var searchTableViewController: SearchViewController = {
		let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
		vc.delegate = self
		return vc
	}()
	
	let topPinViewContainer = UIView()
	let bottomPinViewContainer = UIView()
	let pinView = NSBundle.mainBundle().loadNibNamed("FeedTableViewCell", owner: nil, options: nil)[0] as! FeedTableViewCell
	var pinViewGestureRecognizer: UITapGestureRecognizer!
	
	// MARK: - Lifecycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Feed"
		setupAddButton()
		tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		refreshFeed()
		
		pinViewGestureRecognizer = UITapGestureRecognizer(target: self, action: "togglePlay")
		pinViewGestureRecognizer.delegate = pinView.postView
		pinView.backgroundColor = UIColor.iceLightGray
		
		addHamburgerMenu()
		
		tableView.tableHeaderView = nil
		
		refreshControl = UIRefreshControl()
		customRefresh = ADRefreshControl(refreshControl: refreshControl!)
		refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		rotatePlusButton(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
        
		topPinViewContainer.frame = CGRectMake(0, tableView.frame.minY, view.frame.width, tableView.rowHeight)
		view.superview!.addSubview(topPinViewContainer)
		bottomPinViewContainer.frame = CGRectMake(0, tableView.frame.maxY-tableView.rowHeight, view.frame.width, tableView.rowHeight)
		view.superview!.addSubview(bottomPinViewContainer)
		
		topPinViewContainer.hidden = true
		bottomPinViewContainer.hidden = true
		
		pinView.frame = CGRectMake(0, 0, view.frame.width, tableView.rowHeight)
		
		// Used to update Spotify + button, not very elegant solution
		for cell in (tableView.visibleCells as? [FeedTableViewCell])! {
			cell.postView.updateAddButton()
		}
		
		notConnected()
	}
	
	// MARK: - UIRefreshControl
	
	func refreshFeed() {
		
		notConnected()
		
		API.sharedAPI.fetchFeedOfEveryone { [weak self] in
			self?.posts = $0
			self?.tableView.reloadData()
			
			let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
			dispatch_after(popTime, dispatch_get_main_queue()) { [weak self] in
				// When done requesting/reloading/processing invoke endRefreshing, to close the control
				self?.refreshControl?.endRefreshing()
			}
		}
		
		self.refreshControl?.endRefreshing()
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		cell.postView.post = posts[indexPath.row]
		cell.postView.post?.player.prepareToPlay()
		cell.postView.delegate = self
		return cell
	}
	
	// MARK: - UITableViewDelegate
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		currentlyPlayingIndexPath = indexPath
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		pinIfNeeded()
		customRefresh?.scrollViewDidScroll(scrollView)
	}
	
	func pinIfNeeded() {
		guard let selected = currentlyPlayingIndexPath else { return }
		if pinView.postView.post != posts[selected.row] {
			pinView.postView.post = posts[selected.row]
		}
		guard let selectedCell = tableView.cellForRowAtIndexPath(selected) else { return }
		if selectedCell.frame.minY < tableView.contentOffset.y {
			topPinViewContainer.addSubview(pinView)
			topPinViewContainer.hidden = false
		} else if selectedCell.frame.maxY > tableView.contentOffset.y + tableView.frame.height {
			pinView.postView.post = posts[selected.row]
			bottomPinViewContainer.addSubview(pinView)
			bottomPinViewContainer.hidden = false
		} else {
			topPinViewContainer.hidden = true
			bottomPinViewContainer.hidden = true
		}
	}
	
	func togglePlay() {
		pinView.postView.post?.player.togglePlaying()
	}
	
	func setupAddButton() {
		let image = UIImage(named: "Add")!
		plusButton = UIButton(type: .Custom)
		plusButton.frame = CGRect(origin: CGPointZero, size: image.size)
		plusButton.setImage(image, forState: .Normal)
		plusButton.imageView!.contentMode = .Center
		plusButton.imageView!.clipsToBounds = false
		plusButton.adjustsImageWhenHighlighted = false
		plusButton.addTarget(self, action: "plusButtonTapped", forControlEvents: .TouchUpInside)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
	}
	
	func rotatePlusButton(active: Bool) {
		if let currentTransform = (plusButton.imageView!.layer.presentationLayer() as? CALayer)?.transform {
			plusButton.imageView?.layer.transform = currentTransform
		}
		plusButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
		plusButton.addTarget(active ? searchTableViewController : self, action: active ? "dismiss" : "plusButtonTapped", forControlEvents: .TouchUpInside)
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 30, options: [], animations: {
			let transform = active ? CGAffineTransformMakeRotation(CGFloat(M_PI_4)) : CGAffineTransformIdentity
			self.plusButton.imageView!.transform = transform
			}, completion: nil)
	}
	
	func plusButtonTapped() {
		rotatePlusButton(true)
		
		searchTableViewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		searchTableViewController.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
		navigationController?.pushViewController(searchTableViewController, animated: false)
	}
	
	// MARK: - SongSearchDelegate
	
	func didSelectSong(song: Song) {
		posts.insert(Post(song: song, user: User.currentUser, date: NSDate()), atIndex: 0)
		API.sharedAPI.updatePost(User.currentUser.id, song: song) { [weak self] _ in
			self?.tableView.reloadData()
		}
	}
	
	//MARK: - Navigation
	
	func didTapImageForPostView(postView: PostView) {
		guard let user = postView.post?.user else { return }
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		profileVC.title = "Profile"
		profileVC.user = user
		navigationController?.pushViewController(profileVC, animated: true)
	}

}