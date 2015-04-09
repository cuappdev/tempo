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
    
    let tableViewCellIdentifier = "searchTrackResultsCell"
    var results: [TrackResult] = []
    var delegate: SearchTrackResultsViewControllerDelegate!
    let kSearchBase: String = "https://api.spotify.com/v1/search?type=track&q="
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as UITableViewCell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.text = results[indexPath.row].name
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var alert = UIAlertController(title: "Post song of the day", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            self.postSong(self.results[indexPath.row])
            return
        }))
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // updateSearchResultsForSearchController(_:) is called when the controller is being dismissed to allow resetting the results controller's state. Do not update anything if the controller is being dismissed.
        if !searchController.active {
            return
        }
        
        let searchText = searchController.searchBar.text
        if countElements(searchText) != 0 {
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
        let response = data as NSDictionary
        var tracks = response["tracks"] as NSDictionary
        
        var items = tracks["items"] as NSArray
        
        var trackResults: [TrackResult] = []
        
        for var i = 0; i < items.count; i++ {
            let item = items[i] as NSDictionary
            
            let artists = item["artists"] as NSArray
            let album = item["album"] as NSDictionary
            let id = item["id"] as String
            let name = item["name"] as String
            let uri = item["uri"] as String
            let popularity = item["popularity"] as Int
            
            trackResults.append(
                TrackResult(artists: artists, album: album, id: id, name: name, uri: uri, andPopularity: popularity)
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
    
    // Post a song
    func postSong(track: TrackResult) {
        delegate?.postSong(track)
    }
}