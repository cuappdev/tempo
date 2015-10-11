//
//  SongSearchViewController.swift
//  IceFishing
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

enum SearchType {
    case Song
    case User
}

protocol SongSearchDelegate: class {
	func didSelectSong(song: Song)
}

class SongSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	
	var cellIdentifier = "UserTableViewCell"
    var searchType = SearchType.User
    var users: [User] = []
	
	@IBOutlet weak var searchBarContainer: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var postButtonContainer: UIView!
	
	weak var delegate: SongSearchDelegate?
	
	var results: [Post] = []
	let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
	var activePlayer: Player?
	var lastRequest: Request?
	var selectedSong: Song? {
		didSet {
			postButtonContainer.hidden = selectedSong == nil
		}
	}
	
	var searchBar = UISearchBar()
	lazy var postButton: PostButton = {
		let button = PostButton.instanceFromNib()
		button.addTarget(self, action: "submitSong", forControlEvents: .TouchUpInside)
		return button
	}()
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        beginIceFishing()
        
        if searchType == .Song {
            title = "Post your song of the day!"
            cellIdentifier = "SongSearchTableViewCell"
        } else {
            title = "Search Users"
            cellIdentifier = "UserTableViewCell"
        }
		
		view.backgroundColor = UIColor.iceLightGray
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
		
		searchBar.delegate = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
		
		let textFieldInsideSearchBar = searchBar.valueForKey("_searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
		
		UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
			self.searchBar.layer.transform = CATransform3DIdentity
		}, completion:nil)
		
		searchBar.becomeFirstResponder()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		searchBar.frame = searchBarContainer.bounds
	}
	
	// Called from bar button, not an elegant solution (should audit)
	func dismiss() {
		navigationController?.popViewControllerAnimated(false)
		clearResults()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchType == .Song {
            return results.count
        } else {
            return users.count
        }
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchType == .Song {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SongSearchTableViewCell
            let post = results[indexPath.row]
            cell.postView.post = post
            cell.postView.avatarImageView?.imageURL = post.song.smallArtworkURL
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UserTableViewCell
            let user = users[indexPath.row]
            cell.userName.text = user.name
            cell.numFollowers.text = "Followers: \(user.followersCount)"
			cell.numFollowing.text = "Following: \(user.followingCount)"
            user.loadImage {
                cell.userImage.setBackgroundImage($0, forState: .Normal)
            }
			
            return cell
        }
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchType == .Song {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongSearchTableViewCell
            let post = results[indexPath.row]
            selectSong(post.song)
            
            if activePlayer != nil && activePlayer != cell.postView.post?.player {
                activePlayer!.pause(true)
                activePlayer = nil
            }
            
            cell.postView.post?.player.togglePlaying()
            activePlayer = cell.postView.post?.player
        }
        else {
            let profileView = ProfileViewController()
            profileView.user = users[indexPath.row]
            navigationController?.pushViewController(profileView, animated: true)
        }
	}
    
    // MARK: - General Request Methods
    
    func update(searchText: String) {
        if searchType == .Song {
            lastRequest?.cancel()
            searchText.characters.count != 0 ? initiateRequest(searchText) : clearResults()
        } else {
            searchText.characters.count != 0 ? reloadUserData(searchText) : clearResults()
        }
    }
    
    func clearResults() {
        results = []
        users = []
        selectedSong = nil
        activePlayer?.pause(true)
        activePlayer = nil
        searchBar.text = nil
        tableView.reloadData()
    }
    
    // MARK: - User Request Methods
    
    func reloadUserData(searchText: String) {
        API.sharedAPI.searchUsers(searchText) { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
	
	// MARK: - Song Request Methods
	
	func selectSong(song: Song) {
		if postButton.superview == nil {
			postButton.translatesAutoresizingMaskIntoConstraints = false
			postButtonContainer.addSubview(postButton)
			NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsToFillSuperview(postButton))
		}
		postButton.title = "\(song.title) - \(song.artist)"
		selectedSong = song
		searchBar.resignFirstResponder()
	}
	
	func submitSong() {
		self.delegate?.didSelectSong(selectedSong!)
		dismiss()
	}
	
	func initiateRequest(term: String) {
		let searchUrl = kSearchBase + term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
		lastRequest = Alamofire.request(.GET, searchUrl).responseJSON { _, _, result in
			if let value = result.value as? Dictionary<String, AnyObject> {
				self.receivedResponse(value)
			}
		}
	}
	
	func receivedResponse(response: Dictionary<String, AnyObject>) {
		let songs = response["tracks"] as! Dictionary<String, AnyObject>
		let items = songs["items"] as! Array<Dictionary<String, AnyObject>>
		
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
