//
//  SongSearchViewController.swift
//  IceFishing
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

protocol SongSearchDelegate: class {
	func didSelectSong(song: Song)
}

class SongSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	
	let cellIdentifier = "SongSearchTableViewCell"
	
	weak var delegate: SongSearchDelegate?
	
	var results: [Post] = []
	let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
	var activePlayer: Player?
	var lastRequest: Request?
	var backgroundView: UIView!
	var selectedSong: Song?
	
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarContainer: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var postViewContainer: UIView!
	
	var searchBar = UISearchBar()
	lazy var postButton = PostButton.instanceFromNib()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Post your song of the day!"
		view.backgroundColor = UIColor.iceLightGray
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
		
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		searchBar.delegate = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		searchBarContainer.addSubview(searchBar)
		searchBar.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
		searchBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		view.layoutIfNeeded()
		
		searchBar.frame = searchBarContainer.bounds
		let textFieldInsideSearchBar = searchBar.valueForKey("_searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
		
		self.view.layoutIfNeeded()
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5, options: [], animations: {
			self.searchBar.layer.transform = CATransform3DIdentity
			
			self.view.layoutIfNeeded()
			}) { (completed) -> Void in
				self.searchBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
				self.searchBar.layer.position = self.searchBar.superview!.center
				NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsToFillSuperview(self.searchBar))
		}
		searchBar.becomeFirstResponder()
	}
	
	func dismiss() {
		navigationController?.popViewControllerAnimated(false)
		clearResults()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SongSearchTableViewCell
		let post = results[indexPath.row]
		cell.postView.post = post
		cell.postView.avatarImageView?.imageURL = post.song.smallArtworkURL
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let post = results[indexPath.row]
		selectSong(post.song)
		
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongSearchTableViewCell
		
		if activePlayer != nil && activePlayer != cell.postView.post?.player {
			activePlayer!.pause(true)
			activePlayer = nil
		}
		
		cell.postView.post?.player.togglePlaying()
		activePlayer = cell.postView.post?.player
	}
	
	func selectSong(song: Song) {
		if postButton.superview == nil {
			postButton.translatesAutoresizingMaskIntoConstraints = false
			postViewContainer.addSubview(postButton)
			NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsToFillSuperview(postButton))
			
			postButton.addTarget(self, action: "submitSong", forControlEvents: UIControlEvents.TouchUpInside)
		}
		postButton.title = song.title + " - " + song.artist
		selectedSong = song
		searchBar.resignFirstResponder()
		
		self.bottomConstraint.constant = self.postViewContainer.frame.height
	}
	
	func submitSong() {
		self.delegate?.didSelectSong(selectedSong!)
		dismiss()
	}
	
	func finishSearching() {
		activePlayer?.pause(true)
		activePlayer = nil
	}
	
	func update(searchText: String) {
		lastRequest?.cancel()
		
		if searchText.characters.count != 0 {
			initiateRequest(searchText)
		} else {
			clearResults()
		}
	}
	
	func initiateRequest(term: String) {
		let searchUrl = kSearchBase + term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
		lastRequest = Alamofire.request(.GET, searchUrl).responseJSON { (_, _, result) in
			self.receivedResponse(result.value)
		}
	}
	
	func receivedResponse(data: AnyObject?) {
		guard let data = data else { clearResults(); return }
		
		let response = data as! NSDictionary
		let songs = response["tracks"] as! NSDictionary
		let items = songs["items"] as! NSArray
		
		var postResults: [Post] = []
		for var i = 0; i < items.count; i++ {
			let item = items[i] as! NSDictionary
			let song = Song(responseDictionary: item)
			postResults.append(
				Post(song: song, user: User.currentUser, date: nil, likes: 0)
			)
		}
		
		results = postResults
		tableView.reloadData()
	}
	
	// MARK: - UISearchBarDelegete
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		update(searchText)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	func clearResults() {
		bottomConstraint.constant = 0
		postButton.removeFromSuperview()
		results = []
		tableView.reloadData()
		selectedSong = nil
		activePlayer?.pause(true)
		activePlayer = nil
	}
	
	// MARK: - Notifications
	
	func keyboardWillShow(notification: NSNotification) {
		let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animateWithDuration(duration) {
			self.bottomConstraint.constant = rect.height
			self.view.layoutIfNeeded()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		let const: CGFloat = selectedSong == nil ? 0 : postViewContainer.frame.height
		
		UIView.animateWithDuration(duration) {
			self.bottomConstraint.constant = const
			self.view.layoutIfNeeded()
		}
	}
	
}
