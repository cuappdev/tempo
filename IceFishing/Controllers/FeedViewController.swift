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
	
	lazy var customRefresh: ADRefreshControl = {
		self.refreshControl = UIRefreshControl()
		let customRefresh = ADRefreshControl(refreshControl: self.refreshControl!)
		self.refreshControl?.addTarget(self, action: #selector(refreshFeed), forControlEvents: .ValueChanged)
		return customRefresh
	}()
	
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
		
		//disable user interaction when first loading up feed
		//user interaction gets enabled after refresh is done
		//not very elegant solution, but fixes some UI issues
		view.userInteractionEnabled = false
		
		refreshFeed()
		addHamburgerMenu()
		
		tableView.tableHeaderView = nil
		
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
	
	func refreshFeed() {
		
		//finished refreshing gets set to true when the api returns
		var finishedRefreshing = false
		//minimum time passed gets set to true when minimum delay dispatch gets called
		var minimumTimePassed = false
		
		//fetch data
		self.notConnected()
		
		API.sharedAPI.fetchFeedOfEveryone { [weak self] in
			self?.posts = $0
			
			//return even if we get data after a timeout
			if finishedRefreshing {
				return
			} else if minimumTimePassed {
				self?.tableView.reloadData()
				self?.refreshControl?.endRefreshing()
				self?.view.userInteractionEnabled = true
			}
			finishedRefreshing = true
			
			if let x = self {
				if x.posts.count == 0 {
					let emptyView = UIView.viewForEmptyViewController(.Feed, size: x.view.bounds.size, isCurrentUser: true, userFirstName: "")
					let button = UIButton(frame: CGRect(x: 0, y: 0, width: 190, height: 50))
					button.center = x.view.center
					button.center.y += 90
					button.backgroundColor = UIColor.iceDarkRed
					button.setTitle("Follow more friends", forState: .Normal)
					button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
					button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
					button.layer.cornerRadius = 1.0
					button.addTarget(self, action: #selector(PlayerTableViewController.navigateToSuggestions), forControlEvents: .TouchUpInside)
					
					emptyView.addSubview(button)
					
					x.tableView.backgroundView = emptyView
					
				} else {
					x.tableView.backgroundView = nil
				}
			}
		}
		
		//fetch for a minimum of delay seconds
		//if after delay seconds we finished fetching, 
		//then we reload the tableview, else we wait for the
		//api to return to reload by setting minumum time passed
		var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
		dispatch_after(popTime, dispatch_get_main_queue()) {
			if finishedRefreshing {
				self.tableView.reloadData()
				self.refreshControl?.endRefreshing()
				self.view.userInteractionEnabled = true
			} else {
				minimumTimePassed = true
			}
		}
		
		//timeout for refresh taking too long
		popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
		dispatch_after(popTime, dispatch_get_main_queue()) {
			if !finishedRefreshing {
				self.refreshControl?.endRefreshing()
				self.view.userInteractionEnabled = true
				finishedRefreshing = true
			}
		}
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
		customRefresh.scrollViewDidScroll(scrollView)
	}
	
	func setupAddButton() {
		let image = UIImage(named: "Add")!
		plusButton = UIButton(type: .Custom)
		plusButton.frame = CGRect(origin: CGPointZero, size: image.size)
		plusButton.setImage(image, forState: .Normal)
		plusButton.imageView!.contentMode = .Center
		plusButton.imageView!.clipsToBounds = false
		plusButton.adjustsImageWhenHighlighted = false
		plusButton.addTarget(self, action: #selector(FeedViewController.plusButtonTapped), forControlEvents: .TouchUpInside)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
	}
	
	func rotatePlusButton(active: Bool) {
		if let currentTransform = (plusButton.imageView!.layer.presentationLayer() as? CALayer)?.transform {
			plusButton.imageView?.layer.transform = currentTransform
		}
		plusButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
		plusButton.addTarget(active ? searchTableViewController : self, action: active ? #selector(SearchViewController.dismiss) : #selector(plusButtonTapped), forControlEvents: .TouchUpInside)
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
			self?.refreshFeed()
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
			
			peekViewController.preferredContentSize = CGSizeZero
			previewingContext.sourceRect = postView.convertRect(avatar.frame, toView: tableView)
			
			return peekViewController
		}
		return nil
	}
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		showViewController(viewControllerToCommit, sender: self)
	}
}