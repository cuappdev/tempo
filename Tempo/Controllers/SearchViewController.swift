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
		let searchBarHeight = CGFloat(44)
		tableView = UITableView(frame: CGRect(x: 0, y: searchBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight - searchBarHeight - 20), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.rowHeight = 84
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "SongSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SongSearchTableViewCell")
		
		searchBarContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: searchBarHeight))
		
		searchBar.delegate = self
		playerNav = navigationController as! PlayerNavigationController
		
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
		textFieldInsideSearchBar?.textColor = UIColor.white
		textFieldInsideSearchBar?.backgroundColor = UIColor.tempoDarkRed
		textFieldInsideSearchBar?.font = UIFont(name: "Avenir-Book", size: 14)
		let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
		textFieldInsideSearchBarLabel?.textColor = UIColor.tempoUltraLightRed
		
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
		if let _ = selectedSong {
			playerNav.resetPlayerCells()
		}
		clearResults()
		let _ = navigationController?.popViewController(animated: false)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SongSearchTableViewCell", for: indexPath) as! SongSearchTableViewCell
		let post = results[indexPath.row]
		cell.postView.post = post
		if let smallArtworkURL = post.song.smallArtworkURL {
			cell.postView.avatarImageView?.hnk_setImageFromURL(smallArtworkURL)
		}
		cell.shareButton.isHidden = !(selectedSong?.equals(other: post.song) ?? false)
		if (selfPostIds.contains(post.song.spotifyID)) {
			cell.shareButton.setTitle("SHARED", for: UIControlState())
			cell.shareButton.backgroundColor = UIColor.clear
			cell.shareButton.removeTarget(self, action: #selector(SearchViewController.submitSong), for: .touchUpInside)
		} else {
			cell.shareButton.setTitle("SHARE", for: UIControlState())
			cell.shareButton.backgroundColor = UIColor.tempoLightRed
			cell.shareButton.addTarget(self, action: #selector(SearchViewController.submitSong), for: .touchUpInside)
		}
		
		cell.postView.updatePlayingStatus()
	
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let cell = tableView.cellForRow(at: indexPath) as! SongSearchTableViewCell
		let post = results[indexPath.row]
		
		if selectedSong?.equals(other: post.song) ?? false {
			didTogglePlaying(animate: true)
		} else {
			if activePlayer?.isPlaying ?? false {
				didTogglePlaying(animate: true)
			}
			cell.shareButton.isHidden = false
			selectedCell?.shareButton.isHidden = true
			
			selectSong(post.song)
			selectedCell = cell
			activePlayer = cell.postView.post?.player
			activePlayer?.delegate = self
			didTogglePlaying(animate: true)
			playerNav.updateDelegates(delegate: self)
			playerNav.currentPost = cell.postView.post
			playerNav.postsRef = nil //do not want to autoplay next song
		}
	}
	
    // MARK: - General Request Methods
	
    func update(_ searchText: String) {
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
	
	func selectSong(_ song: Song) {
		selectedSong = song
		searchBar.resignFirstResponder()
	}
	
	func submitSong() {
		delegate?.didSelectSong(selectedSong!)
		dismiss()
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
		
		results = items.map {
			let song = Song(responseDictionary: $0)
			let post = Post(song: song, user: User.currentUser)
			post.player.prepareToPlay()
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
	
	// MARK: - PausePlayDelegate
	
	func didTogglePlaying(animate: Bool) {
		if let activePlayer = activePlayer {
			activePlayer.togglePlaying()
		}
		selectedCell?.postView.updatePlayingStatus()
		playerNav.updatePlayingStatus()
	}
	
	func didFinishPlaying() {
		selectedCell?.postView.updatePlayingStatus()
		playerNav.updatePlayingStatus()
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
