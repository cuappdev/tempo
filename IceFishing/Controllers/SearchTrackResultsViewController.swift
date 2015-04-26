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
    
    let tableViewCellIdentifier = "searchTrackResultsCell"
    var results: [TrackResult] = []
    var delegate: SearchTrackResultsViewControllerDelegate!
    let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
    var hasSelectedResult = false
    var activePlayer: Player!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.iceDarkGray()
        tableView.backgroundColor = UIColor.iceDarkGray()
        tableView.separatorColor = UIColor.clearColor()
        tableView.separatorStyle = .None;
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
        if cell.postView.post != nil {
            cell.postView.post!.player.destroy()
        }

        let track = results[indexPath.row]
        cell.postView.post = Post(trackResult: track,
            posterFirst: track.artists[0]["name"]!,
            posterLast: "",
            date: nil,
            avatar: transparentPNG(36))
        cell.postView.flagAsSearchResultPost()
        cell.postView.post?.player.prepareToPlay()
        if let artwork = track.album["artwork"] as String? {
            loadImageAsync(artwork, { image, error in
                if error == nil {
                    cell.postView.setImage(image)
                }
            })
        }
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

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
        } else {

        }
    }
    
    // MARK: Search Functions
    
    // Example results url: https://api.spotify.com/v1/search?type=track&q=kanye
    func initiateRequest(term: String) {
        var searchUrl = kSearchBase + term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        
        Alamofire.request(.GET, searchUrl)
            .responseJSON { (request, response, data, error) in
                self.receivedResponse(data)
                return
        }
    }
    
    // Saves json as new results Track array and reloads table
    func receivedResponse(data: AnyObject?) {
        let response = data as! NSDictionary
        var tracks = response["tracks"] as! NSDictionary
        
        var items = tracks["items"] as! NSArray
        
        var trackResults: [TrackResult] = []
        
        for var i = 0; i < items.count; i++ {
            let item = items[i] as! NSDictionary
            
            let artists = item["artists"] as! NSArray
            let album = item["album"] as! NSDictionary
            let id = item["id"] as! String
            let name = item["name"] as! String
            let uri = item["uri"] as! String
            let popularity = item["popularity"] as! Int
            
            trackResults.append(
                TrackResult(artists: artists as [AnyObject], album: album, id: id, name: name, uri: uri, andPopularity: popularity)
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
