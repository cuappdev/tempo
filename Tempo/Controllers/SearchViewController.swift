//
//  SearchViewController.swift
//  Tempo
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

protocol SongSearchDelegate: class {
	func didSelectSong(song: Song)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PlayerDelegate {

	@IBOutlet weak var searchBarContainer: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	weak var delegate: SongSearchDelegate?
	
	var results: [Post] = []
	let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
	var activePlayer: Player?
	var lastRequest: Request?
	var selectedSong: Song?
	var selectedCell: SongSearchTableViewCell?
	var searchBar = UISearchBar()
	var selfPostIds: [String] = []
	var playerNav: PlayerNavigationController!
	
	private var keyboardShowNotificationHandler: AnyObject?
	private var keyboardHideNotificationHandler: AnyObject?
	
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Post a track"
		view.backgroundColor = UIColor.tempoDarkGray
		tableView.rowHeight = 84
		tableView.showsVerticalScrollIndicator = false
		tableView.registerNib(UINib(nibName: "SongSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SongSearchTableViewCell")
		
		searchBar.delegate = self
		playerNav = navigationController as! PlayerNavigationController
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		searchBarContainer.addSubview(searchBar)
		var trans = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
		trans.m34 = 1.0 / -400
		searchBar.layer.transform = trans
		searchBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		view.layoutIfNeeded()
		tableView.tableFooterView = UIView()
		
		let textFieldInsideSearchBar = searchBar.valueForKey("_searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
		textFieldInsideSearchBar?.backgroundColor = UIColor.tempoDarkRed
		textFieldInsideSearchBar?.font = UIFont(name: "Avenir-Book", size: 14)
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.valueForKey("placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = UIColor.tempoUltraLightRed
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
			self.searchBar.layer.transform = CATransform3DIdentity
		}, completion:nil)
		
		searchBar.becomeFirstResponder()
		searchBar.setImage(UIImage(named: "search-icon"), forSearchBarIcon: .Search, state: .Normal)
		searchBar.setImage(UIImage(named: "clear-search-icon"), forSearchBarIcon: .Clear, state: .Normal)
		
		if notConnected(true) {
			searchBar.hidden = true
			searchBar.userInteractionEnabled = false
		} else {
			searchBar.hidden = false
			searchBar.userInteractionEnabled = true
			searchBar.becomeFirstResponder()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		searchBar.frame = searchBarContainer.bounds
	}
	
	// Called from bar button, not an elegant solution (should audit)
	func dismiss() {
		clearResults()
		navigationController?.popViewControllerAnimated(false)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("SongSearchTableViewCell", forIndexPath: indexPath) as! SongSearchTableViewCell
		let post = results[indexPath.row]
		cell.postView.post = post
		cell.postView.post?.player.prepareToPlay()
		cell.postView.avatarImageView?.hnk_setImageFromURL(post.song.smallArtworkURL!)
		cell.shareButton.hidden = true
		if (selfPostIds.contains(post.song.spotifyID)) {
			cell.shareButton.setTitle("SHARED", forState: .Normal)
			cell.shareButton.backgroundColor = UIColor.clearColor()
			cell.shareButton.removeTarget(self, action: #selector(SearchViewController.submitSong), forControlEvents: .TouchUpInside)
		} else {
			cell.shareButton.setTitle("SHARE", forState: .Normal)
			cell.shareButton.backgroundColor = UIColor.tempoLightRed
			cell.shareButton.addTarget(self, action: #selector(SearchViewController.submitSong), forControlEvents: .TouchUpInside)
		}
		if activePlayer != nil {
			if activePlayer == post.player {
				cell.postView.profileNameLabel?.textColor = UIColor.tempoLightRed
				cell.shareButton.hidden = false
			} else {
				cell.postView.profileNameLabel?.textColor = UIColor.whiteColor()
			}
		}
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if selectedCell != nil {
			selectedCell?.shareButton.hidden = true
		}
		
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongSearchTableViewCell
		selectedCell = cell
		cell.shareButton.hidden = false
		
		let post = results[indexPath.row]
		selectSong(post.song)
		
		if activePlayer != nil && activePlayer != cell.postView.post?.player {
			activePlayer!.pause()
			activePlayer = nil
		}
		
		activePlayer = cell.postView.post?.player
		activePlayer?.delegate = self
		didTogglePlaying(true)
		playerNav.playerCell.postsLikable = false
		playerNav.expandedCell.postsLikable = false
		playerNav.expandedCell.postHasInfo = false
		playerNav.currentPost = cell.postView.post
		playerNav.postsRef = nil //do not want to autoplay next song
	}
	
    // MARK: - General Request Methods
	
    func update(searchText: String) {
		lastRequest?.cancel()
		searchText.characters.count != 0 ? initiateRequest(searchText) : clearResults()
    }
	
    func clearResults() {
        results = []
        selectedSong = nil
        searchBar.text = nil
        tableView.reloadData()
    }
	
	// MARK: - Song Request Methods
	
	func selectSong(song: Song) {
		selectedSong = song
		searchBar.resignFirstResponder()
	}
	
	func submitSong() {
		delegate?.didSelectSong(selectedSong!)
		dismiss()
	}
	
	func initiateRequest(term: String) {
		let searchUrl = kSearchBase + term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
		lastRequest = Alamofire.request(.GET, searchUrl).responseJSON { response in
			if let value = response.result.value as? [String: AnyObject] {
				self.receivedResponse(value)
			}
		}
	}
	
	func receivedResponse(response: [String: AnyObject]) {
		let songs = response["tracks"] as! [String: AnyObject]
		let items = songs["items"] as! [[String: AnyObject]]
		
		results = items.map {
			let song = Song(responseDictionary: $0)
			return Post(song: song, user: User.currentUser)
		}
		
		tableView.reloadData()
	}
	
	// MARK: - UISearchBarDelegete
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		update(searchText)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	// MARK: - PausePlayDelegate
	
	func didTogglePlaying(animate: Bool) {
		if let activePlayer = activePlayer {
			activePlayer.togglePlaying()
			selectedCell?.postView.updatePlayingStatus()
		}
	}
	
	// MARK: - Notifications
	
	func keyboardWillShow(notification: NSNotification) {
		let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animateWithDuration(duration) {
			self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
			self.view.layoutIfNeeded()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animateWithDuration(duration) {
			self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.searchBar.frame.height, right: 0)
			self.view.layoutIfNeeded()
		}
	}
	
}
