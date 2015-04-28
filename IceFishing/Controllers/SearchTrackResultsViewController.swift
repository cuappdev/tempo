//
//  SearchTrackResultsViewController.swift
//  SpotifySearch
//
//  Created by Austin Chan on 3/15/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit
import Alamofire

class SearchTrackResultsViewController: UITableViewController, UISearchResultsUpdating {
    
    // MARK: Properties
    
    let kSearchResultHeight: CGFloat = 72
    weak var parent: FeedViewController?
    var shouldResume = false
    let tableViewCellIdentifier = "searchTrackResultsCell"
    var results: [Song] = []
    var delegate: SearchTrackResultsViewControllerDelegate!
    let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
    var hasSelectedResult = false
    var activePlayer: Player!
    let missingImage = transparentPNG(36)
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.iceDarkGray()
        tableView.backgroundColor = UIColor.iceDarkGray()
        tableView.separatorColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return hasSelectedResult ? kSearchResultHeight : CGFloat(0)
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
        let track = results[indexPath.row]
        cell.postView.post = Post(song: track, posterFirst: track.artist, posterLast: "", date: nil, avatar: missingImage)
        cell.postView.flagAsSearchResultPost()
        if let artwork = track.albumArtworkURL {
            loadImageAsync(artwork, { image, error in
                if error == nil {
                    cell.postView.setImage(image)
                }
            })
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let post = parent?.currentlyPlayingPost {
            post.player.pause(false)
        }
        
        let track = results[indexPath.row]
        delegate.selectSong(track)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
        
        if activePlayer != nil && activePlayer != cell.postView.post?.player {
            activePlayer.destroy()
        }

        cell.postView.post?.player.togglePlaying()
        
        addBottomSpace()
        activePlayer = cell.postView.post?.player
    }
    
    func addBottomSpace() {
        tableView.beginUpdates()
        hasSelectedResult = true
        tableView.endUpdates()
    }
    
    func finishSearching() {
        if activePlayer != nil {
            activePlayer.destroy()
        }
        
        if (shouldResume) {
            if let post = parent?.currentlyPlayingPost {
                post.player.play(false)
            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // updateSearchResultsForSearchController(_:) is called when the controller is being dismissed to allow resetting the results controller's state. Do not update anything if the controller is being dismissed.
        if !searchController.active {
            return
        }
        
        let searchText = searchController.searchBar.text
        if count(searchText) != 0 {
            initiateRequest(searchText)
        }
    }
    
    // MARK: Search Functions
    
    // Example results url: https://api.spotify.com/v1/search?type=track&q=kanye
    func initiateRequest(term: String) {
        var searchUrl = kSearchBase + term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.request(.GET, searchUrl)
            .responseJSON { (request, response, data, error) in
                self.receivedResponse(data)
        }
    }
    
    // Saves json as new results Track array and reloads table
    func receivedResponse(data: AnyObject?) {
        let response = data as! NSDictionary
        var tracks = response["tracks"] as! NSDictionary
        
        var items = tracks["items"] as! NSArray
        
        var trackResults: [Song] = []
        
        for var i = 0; i < items.count; i++ {
            let item = items[i] as! NSDictionary
//            
//            let artists = item["artists"] as! NSArray
//            let album = item["album"] as! NSDictionary
//            let id = item["id"] as! String
//            let name = item["name"] as! String
//            let uri = item["uri"] as! String
//            let popularity = item["popularity"] as! Int
//            
            trackResults.append(
                Song(responseDictionary: item)
            )
        }

        results = trackResults
        tableView.reloadData()
    }
    
    // Empty results and reload table
    func clearResults() {
        results = []
        tableView.reloadData()
    }

}
