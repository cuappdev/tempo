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
	
	var pretappedPlusButton = false

	// MARK: - Lifecycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Feed"
		setupAddButton()
		tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
		
		refreshFeed()
		addHamburgerMenu()
		
		tableView.tableHeaderView = nil
		
		refreshControl = UIRefreshControl()
		customRefresh = ADRefreshControl(refreshControl: refreshControl!)
		refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
		
		// Check for 3D Touch availability
		if #available(iOS 9.0, *) {
			if traitCollection.forceTouchCapability == .Available {
				registerForPreviewingWithDelegate(self, sourceView: view)
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//Begin a post if coming from a quick action
		if pretappedPlusButton {
			plusButtonTapped()
			pretappedPlusButton = false
		} else {
			rotatePlusButton(false)
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
        

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
			
			if let x = self {
				if x.posts.count == 0 {
					let emptyView = UIView.viewForEmptyViewController(.Feed, size: x.view.bounds.size, isCurrentUser: true, userFirstName: "")
					let button = UIButton(frame: CGRect(x: 0, y: 0, width: 190, height: 35))
					button.center = x.view.center
					button.center.y += 65
					button.backgroundColor = UIColor.iceDarkRed
					button.setTitle("Follow more friends", forState: .Normal)
					button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
					button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
					button.layer.cornerRadius = 5.0
					button.addTarget(self, action: "navigateToSuggestions", forControlEvents: .TouchUpInside)
					
					emptyView.addSubview(button)
					
					x.tableView.backgroundView = emptyView
					
				} else {
					x.tableView.backgroundView = nil
				}
			}
			
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
		super.scrollViewDidScroll(scrollView)
		customRefresh?.scrollViewDidScroll(scrollView)
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
	
	// MARK: - Navigation
	
	func didTapImageForPostView(postView: PostView) {
		guard let user = postView.post?.user else { return }
		let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		profileVC.title = "Profile"
		profileVC.user = user
		navigationController?.pushViewController(profileVC, animated: true)
	}

}

@available(iOS 9.0, *)
extension FeedViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		let tableViewPoint = view.convertPoint(location, toView: tableView)
		
		guard let indexPath = tableView.indexPathForRowAtPoint(tableViewPoint),
			cell = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewCell else {
				return nil
		}
		
		let postView = cell.postView
		guard let avatar = postView.avatarImageView else { return nil }
		
		let avatarFrame = postView.convertRect(avatar.frame, toView: tableView)
		
		if avatarFrame.contains(tableViewPoint) {
			guard let user = postView.post?.user else { return nil }
			let peekViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
			peekViewController.title = "Profile"
			peekViewController.user = user
			
			peekViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
			previewingContext.sourceRect = postView.convertRect(avatar.frame, toView: tableView)
			
			return peekViewController
		}
		return nil
	}
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		showViewController(viewControllerToCommit, sender: self)
	}
}