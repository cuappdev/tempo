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
	func didSelectSong(_ song: Song)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PlayerDelegate {

	var tableView: UITableView!
	
	var searchBarContainer: UIView!
	var searchBar = UISearchBar()
	let searchBarHeight: CGFloat = 44
	let shareButtonWidth: CGFloat = 96
	
	let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
	var lastRequest: Request?
	
	weak var delegate: SongSearchDelegate?
	let playerCenter = PlayerCenter.sharedInstance
	
	var posts: [Post] = []
	var selectedCell: SongSearchTableViewCell?
	var selfPostIds: [String] = []

	
	private var keyboardShowNotificationHandler: AnyObject?
	private var keyboardHideNotificationHandler: AnyObject?
	
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.readCellColor
		
		title = "Post a track"
		
		tableView = UITableView(frame: CGRect(x: 0, y: searchBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabBarHeight - searchBarHeight - 20), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		
		tableView.rowHeight = 89
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "SongSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SongSearchTableViewCell")
		
		searchBarContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: searchBarHeight))
		
		searchBar.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		view.addSubview(searchBarContainer)
		view.addSubview(tableView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		searchBarContainer.addSubview(searchBar)
		var trans = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
		trans.m34 = 1.0 / -400
		searchBar.layer.transform = trans
		searchBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		view.layoutIfNeeded()
		tableView.tableFooterView = UIView()
		
		let textFieldInsideSearchBar = searchBar.value(forKey: "_searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = .white
		textFieldInsideSearchBar?.backgroundColor = .searchBackgroundRed
		textFieldInsideSearchBar?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		textFieldInsideSearchBar?.keyboardAppearance = .dark
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = .searchTextColor
		
		UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
			self.searchBar.layer.transform = CATransform3DIdentity
		}, completion:nil)
		
		searchBar.becomeFirstResponder()
		searchBar.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .search, state: UIControlState())
		searchBar.setImage(#imageLiteral(resourceName: "ClearSearchIcon"), for: .clear, state: UIControlState())
		
		if notConnected(true) {
			searchBar.isHidden = true
			searchBar.isUserInteractionEnabled = false
		} else {
			searchBar.isHidden = false
			searchBar.isUserInteractionEnabled = true
			searchBar.becomeFirstResponder()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		searchBar.frame = searchBarContainer.bounds
	}
	
	// Called from bar button, not an elegant solution (should audit)
	func dismiss() {
		if let _ = playerCenter.getCurrentPost() {
			playerCenter.resetPlayerCells()
		}
		clearPosts()
		let _ = navigationController?.popViewController(animated: false)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SongSearchTableViewCell", for: indexPath) as! SongSearchTableViewCell
		let post = posts[indexPath.row]
		cell.postView.avatarImageView?.image = nil
		cell.postView.post = post
		if let smallArtworkURL = post.song.smallArtworkURL {
			cell.postView.avatarImageView?.hnk_setImageFromURL(smallArtworkURL)
		}
		
		if let currentPost = playerCenter.getCurrentPost() {
			cell.shareButton.isHidden = !currentPost.equals(other: post)
		} else {
			cell.shareButton.isHidden = true
		}
		
		if (selfPostIds.contains(post.song.spotifyID)) {
			cell.shareButton.setTitle("SHARED", for: UIControlState())
			cell.shareButton.backgroundColor = .clear
			cell.shareButton.removeTarget(self, action: #selector(SearchViewController.submitSong), for: .touchUpInside)
		} else {
			cell.shareButton.setTitle("SHARE", for: UIControlState())
			cell.shareButton.backgroundColor = .tempoRed
			cell.shareButton.addTarget(self, action: #selector(SearchViewController.submitSong), for: .touchUpInside)
		}
		
		cell.postView.updatePlayingStatus()
	
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let cell = tableView.cellForRow(at: indexPath) as! SongSearchTableViewCell
		let post = posts[indexPath.row]
		
		if let currentPost = playerCenter.getCurrentPost(), currentPost.equals(other: post) {
			didTogglePlaying(animate: true)
		} else {
			//hide shareButton for previous cell, if needed
			selectedCell?.shareButton.isHidden = true
			selectedCell?.shareButtonWidthConstraint.constant = 0
			
			//show shareButton for current cell
			cell.shareButton.isHidden = false
			cell.shareButtonWidthConstraint.constant = shareButtonWidth
			
			selectSong(post, selectedCell?.postView)
			selectedCell = cell
		}
	}
	
    // MARK: - General Request Methods
	
    func update(_ searchText: String) {
		lastRequest?.cancel()
		searchText.characters.count != 0 ? initiateRequest(searchText) : clearPosts()
    }
	
    func clearPosts() {
        posts = []
        searchBar.text = nil
        tableView.reloadData()
    }
	
	// MARK: - Song Request Methods
	
	func selectSong(_ post: Post, _ postView: PostView?) {
		playerCenter.updateNewPost(post: post, delegate: self, postsRef: nil, postRefIndex: nil, postView: postView)
		searchBar.resignFirstResponder()
	}
	
	func submitSong() {
		// shouldn't be able to get here if playerNav.currentPost is nil
		delegate?.didSelectSong(playerCenter.getCurrentPost()!.song)
		TabBarController.sharedInstance.programmaticallyPressTabBarButton(atIndex: 0)
	}
	
	func initiateRequest(_ term: String) {
		let searchUrl = kSearchBase + term.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
		lastRequest = Alamofire.request(searchUrl).responseJSON { response in
			if let value = response.result.value as? [String: AnyObject] {
				self.receivedResponse(value)
			}
		}
	}
	
	func receivedResponse(_ response: [String: AnyObject]) {
		let songs = response["tracks"] as! [String: AnyObject]
		let items = songs["items"] as! [[String: AnyObject]]
		
		posts = items.map {
			let song = Song(responseDictionary: $0)
			let post = Post(song: song, user: User.currentUser)
			post.player.delegate = self
			post.postType = .search
			return post
		}
		
		tableView.reloadData()
	}
	
	// MARK: - UISearchBarDelegete
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		update(searchText)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	// MARK: - PlayerDelegate
	
	func didTogglePlaying(animate: Bool) {
		if let currentPost = playerCenter.getCurrentPost() {
			currentPost.player.togglePlaying()
		}
		selectedCell?.postView.updatePlayingStatus()
		playerCenter.updatePlayingStatus()
	}
	
	func didFinishPlaying() {
		didTogglePlaying(animate: true)
	}	
	
	// MARK: - Notifications
	
	func keyboardWillShow(_ notification: Notification) {
		let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animate(withDuration: duration, animations: {
			self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
			self.view.layoutIfNeeded()
		}) 
	}
	
	func keyboardWillHide(_ notification: Notification) {
		let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animate(withDuration: duration, animations: {
			self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.searchBar.frame.height, right: 0)
			self.view.layoutIfNeeded()
		}) 
	}
	
}
