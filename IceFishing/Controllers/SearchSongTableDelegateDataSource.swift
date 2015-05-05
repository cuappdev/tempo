//
//  SearchSongTableDelegateDataSource.swift
//  IceFishing
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

class SearchSongTableDelegateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    let kSearchResultHeight: CGFloat = 54
    weak var parent: FeedViewController?
    var shouldResume = false
    var results: [Post] = []
    let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
    var hasSelectedResult = false
    var activePlayer: Player!
    let missingImage = transparentPNG(36)
    var tableView: UITableView!
    var lastRequest: Alamofire.Request!
    var lastTerm: String = ""
    var keyboardHeight: CGFloat = 0
    var backgroundView: UIView!
    var bottomView: UIView!
    var selectedSong: Song!
    
    // MARK: UITableViewDataSource
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    convenience init(parent: FeedViewController, table: UITableView, bottom: UIView) {
        self.init()
        tableView = table

        backgroundView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
        var backgroundLabel = UILabel()
        backgroundLabel.text = "Post your song of the day!"
        backgroundLabel.font = UIFont(name: "AvenirNext-Medium", size: 21)
        backgroundLabel.textColor = UIColor(white: 153/255.0, alpha: 1)
        backgroundLabel.textAlignment = NSTextAlignment.Center
        backgroundLabel.sizeToFit()
        backgroundLabel.frame.size.width = screenSize.width
        backgroundLabel.frame.origin.y = 235
        var backgroundGlass = UIImageView(frame: CGRectMake((screenSize.width - 95)/2, 115, 95, 95))
        backgroundGlass.image = UIImage(named: "search-glass")
        backgroundView.addSubview(backgroundGlass)
        backgroundView.addSubview(backgroundLabel)
        
        bottomView = bottom
        
        self.parent = parent
        
        // Pause main feed if it's playing.
        if let post = self.parent?.currentlyPlayingPost {
            post.player.pause(false)
        }
    }
    
    deinit {
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if results.count == 0 && count(lastTerm) == 0 {
            tableView.backgroundView = backgroundView
            return 0
        }

        tableView.backgroundView = UIView()
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height = keyboardHeight
        if hasSelectedResult && height == 0 {
            height += kSearchResultHeight
        }
        return height
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("searchSongResultsCell", forIndexPath: indexPath) as! SearchSongTableViewCell
        let post = results[indexPath.row]
        cell.postView.post = post
        cell.postView.avatarImageView?.placeholderImage = missingImage
        cell.postView.avatarImageView?.imageURL = post.song.largeArtworkURL
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let post = results[indexPath.row]
        selectSong(post.song)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchSongTableViewCell
//        
        if activePlayer != nil && activePlayer != cell.postView.post?.player {
            activePlayer.pause(true)
            activePlayer = nil
        }

        cell.postView.post?.player.togglePlaying()
        
        addBottomSpace()
        activePlayer = cell.postView.post?.player
    }
    
    func selectSong(song: Song) {
        if let previousSelectionView = bottomView.viewWithTag(150) {
            previousSelectionView.removeFromSuperview()
        }
        
        var selectionView = NSBundle.mainBundle().loadNibNamed("SearchResultSelectionView", owner: self, options: nil).first as! UIView
        
        bottomView.addSubview(selectionView)
        selectionView.frame.size.width = screenSize.width
        
        UIView.animateWithDuration(0.3, animations: {
            var frame = self.bottomView.frame
            frame.origin.y = screenSize.height - CGFloat(self.kSearchResultHeight)
            self.bottomView.frame = frame
        })
        
        var firstLabel = selectionView.viewWithTag(2) as! UILabel
        var button = selectionView.viewWithTag(4) as! UIButton

        firstLabel.text = song.title + " - " + song.artist
        button.addTarget(self, action: "submitSong", forControlEvents: UIControlEvents.TouchUpInside)
        
        selectedSong = song
        
        parent?.selectSong()
    }
    
    func submitSong() {
        parent?.submitSong(selectedSong)
    }
    
    func keyboardFrameChanged(notification: NSNotification) {
        var rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        println(rect)
        tableView.beginUpdates()
        keyboardHeight = screenSize.height - rect!.origin.y
        tableView.endUpdates()
    }
    
    func addBottomSpace() {
        tableView.beginUpdates()
        hasSelectedResult = true
        tableView.endUpdates()
    }
    
    func finishSearching() {
        if activePlayer != nil {
            activePlayer.pause(true)
            activePlayer = nil
        }
        
        if (shouldResume) {
            if let post = parent?.currentlyPlayingPost {
                post.player.play(false)
            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func update(searchText: String) {
        if lastRequest != nil {
            lastRequest.cancel()
        }
        
        lastTerm = searchText

        if count(searchText) != 0 {
            initiateRequest(searchText)
        } else {
            results = []
            tableView.reloadData()
        }
    }
    
    // MARK: Search Functions
    
    // Example results url: https://api.spotify.com/v1/search?type=track&q=kanye
    func initiateRequest(term: String) {
        var searchUrl = kSearchBase + term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        lastRequest = Alamofire.request(.GET, searchUrl)
            .responseJSON { (request, response, data, error) in
                if error != nil {
                    return
                }

                self.lastRequest = nil
                self.receivedResponse(data)
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
        var songs = response["tracks"] as! NSDictionary
        
        var items = songs["items"] as! NSArray
        
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
