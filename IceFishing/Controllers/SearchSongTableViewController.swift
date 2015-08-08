//
//  SearchSongTableViewController.swift
//  IceFishing
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

// FIXME: This entire class should really be a UITableViewController
class SearchSongTableViewController: UITableViewController, UISearchResultsUpdating {
    
    // MARK: Properties
	let cellIdentifier = "SearchSongTableViewCell"
	let searchController = UISearchController(searchResultsController: nil)
    
    let kSearchResultHeight: CGFloat = 54
    var shouldResume = false
    var results: [Post] = []
    let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
    var activePlayer: Player!
    var lastRequest: Alamofire.Request!
    var keyboardHeight: CGFloat = 0
    var backgroundView: UIView!
    var selectedSong: Song!
	
	lazy var postButton = PostButton.instanceFromNib()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		beginIceFishing()
		title = "Post your song of the day!"
		tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
		tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
		tableView.separatorStyle = .None
		tableView.rowHeight = 96
		
		searchController.searchResultsUpdater = self
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		update("Everybody Backstreet")
	}
	
	func closeSearch(sender: UIButton) {
		navigationController?.popViewControllerAnimated(false)
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		update("Everybody Backstreet")
	}
	
    // MARK: UITableViewDataSource
    
//    override init() {
//        super.init()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillHideNotification, object: nil)
//    }
	
//    convenience init(parent: FeedViewController, table: UITableView, bottom: UIView) {
//        self.init()
//        tableView = table
//
//        backgroundView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
//        let backgroundLabel = UILabel()
//        backgroundLabel.text = "Post your song of the day!"
//        backgroundLabel.font = UIFont(name: "AvenirNext-Medium", size: 21)
//        backgroundLabel.textColor = UIColor(white: 153/255.0, alpha: 1)
//        backgroundLabel.textAlignment = NSTextAlignment.Center
//        backgroundLabel.sizeToFit()
//        backgroundLabel.frame.size.width = screenSize.width
//        backgroundLabel.frame.origin.y = 235
//        let backgroundGlass = UIImageView(frame: CGRectMake((screenSize.width - 95)/2, 115, 95, 95))
//        backgroundGlass.image = UIImage(named: "Search-Glass")
//        backgroundView.addSubview(backgroundGlass)
//        backgroundView.addSubview(backgroundLabel)
//        
//        bottomView = bottom
	
//        self.parent = parent
		
        // Pause main feed if it's playing.
//        if let post = self.parent?.currentlyPlayingPost {
//            post.player.pause(false)
//        }
//    }
	
	func dismiss() {
		navigationController?.popViewControllerAnimated(false)
		if activePlayer != nil {
			activePlayer.pause(true)
			activePlayer = nil
		}
	}
	
    deinit {
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if results.count == 0 {
            tableView.backgroundView = backgroundView
            return 0
        }

        tableView.backgroundView = UIView()
        return 1
    }
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SearchSongTableViewCell
        let post = results[indexPath.row]
        cell.postView.post = post
        cell.postView.avatarImageView?.imageURL = post.song.largeArtworkURL
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let post = results[indexPath.row]
        selectSong(post.song)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchSongTableViewCell

        if activePlayer != nil && activePlayer != cell.postView.post?.player {
            activePlayer.pause(true)
            activePlayer = nil
        }

        cell.postView.post?.player.togglePlaying()
        activePlayer = cell.postView.post?.player
    }

    func selectSong(song: Song) {
		if postButton.superview == nil {
			postButton.translatesAutoresizingMaskIntoConstraints = false
			navigationController?.view.addSubview(postButton)
			var constraints: [NSLayoutConstraint] = []
			constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v" : postButton])
			constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[v(==50)]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v" : postButton])
			let bottomConstraint = NSLayoutConstraint(item: postButton, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: navigationController?.view, attribute: .Bottom, multiplier: 1, constant: 50)
			constraints.append(bottomConstraint)
			NSLayoutConstraint.activateConstraints(constraints)
			
			navigationController?.view.layoutIfNeeded()
			bottomConstraint.constant = 0
			UIView.animateWithDuration(0.4, animations: { () -> Void in
				navigationController?.view.layoutIfNeeded()
			})
			
//			NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsToFillSuperview(postButton))
		}
//        let screenSize = self.view.frame.size
//        UIView.animateWithDuration(0.3, animations: {
//            self.bottomView.frame = CGRectMake(0, screenSize.height - self.kSearchResultHeight, self.bottomView.frame.width, self.kSearchResultHeight)
//        })

        postButton.title = song.title + " - " + song.artist
        postButton.addTarget(self, action: "submitSong", forControlEvents: UIControlEvents.TouchUpInside)
        
        selectedSong = song
    }
    
    func submitSong() {
		
    }
    
    func keyboardFrameChanged(notification: NSNotification) {
        let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        print(rect)
        tableView.beginUpdates()
//        keyboardHeight = screenSize.height - rect!.origin.y
        tableView.endUpdates()
    }
	
    func finishSearching() {
        if activePlayer != nil {
            activePlayer.pause(true)
            activePlayer = nil
        }
        
        if (shouldResume) {
//            if let post = parent?.currentlyPlayingPost {
//                post.player.play(false)
//            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func update(searchText: String) {
        if lastRequest != nil {
			print("Cancelling")
            lastRequest.cancel()
        }

        if searchText.characters.count != 0 {
            initiateRequest(searchText)
        } else {
            results = []
            tableView.reloadData()
        }
    }
    
    // MARK: Search Functions
    
    // Example results url: https://api.spotify.com/v1/search?type=track&q=kanye
    func initiateRequest(term: String) {
		// Changed this, but not actually sure it is correct (may be source of search errors otherwise)
		let searchUrl = kSearchBase + term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        lastRequest = Alamofire.request(.GET, searchUrl)
            .responseJSON { (request, response, result) in
                if result.isFailure {
                    print(result.error)
                }

                self.lastRequest = nil
                self.receivedResponse(result.value)
        }
    }
    
    // Saves json as new results Song array and reloads table
    func receivedResponse(data: AnyObject?) {
        if (data == nil) {
            results = []
            tableView.reloadData()
            return
        }
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
    
    // Empty results and reload table
    func clearResults() {
        results = []
        tableView.reloadData()
    }

}
