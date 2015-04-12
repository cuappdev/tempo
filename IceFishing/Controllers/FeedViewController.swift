//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController, UIScrollViewDelegate {
    var pinView: UIView = UIView()
    var posts: [Post] = []
    var currentlyPlayingIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(NSDate())")
        
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        var post = Post(song: Song(songID: "3TV9xKWFOxndERab4wwxsj"), posterFirst: "Mark", posterLast: "Bryan", date: NSDate(), avatar: UIImage(named: "Sexy"))
        posts.append(post)
    }
    
    //Mark: - UIRefreshControl
    
    func refreshFeed() {
//        testSongIDs.append("https://p.scdn.co/mp3-preview/dba0ce6ac6310d7be00545861f9b58aeb86930a3")
//        testSongDescriptions.append("Don't Stop the Party - Pitbull")

        self.tableView.reloadData()
        
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as FeedTableViewCell
        cell.postView.post = posts[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.0;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.isEqual(currentlyPlayingIndexPath)) {
            posts[indexPath.row].player.togglePlaying()
        } else {
            posts[indexPath.row].player.play()
        }
        currentlyPlayingIndexPath = indexPath
        
        if tableView.indexPathForSelectedRow() != nil { //If a row is selected
            view.addSubview(pinView)
            //println("lol")
            let selectedRow = tableView.indexPathForSelectedRow()! //Selected Row
            let rowsICanSee = tableView.indexPathsForVisibleRows() as [NSIndexPath] //Rows Seen
            let cellSelected = tableView.cellForRowAtIndexPath(selectedRow)
            if rowsICanSee.first == selectedRow || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
                pinView.backgroundColor = cellSelected!.backgroundColor
                if rowsICanSee.first == selectedRow {
                    pinView.center = CGPoint(x: view.center.x, y: 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                } else if rowsICanSee.last == selectedRow {
                    pinView.center = CGPoint(x: view.center.x, y: view.frame.height - 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                }
                
            }
                
            else {
                if selectedRow.compare(rowsICanSee.first!) != selectedRow.compare(rowsICanSee.last!) { //If they're equal then the thing is not on screen
                    pinView.center = CGPoint(x: cellSelected!.center.x, y: cellSelected!.center.y - tableView.contentOffset.y)
                    pinView.backgroundColor = cellSelected!.backgroundColor
                }
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if let selectedRow = tableView.indexPathForSelectedRow() { //If a row is selected
            view.addSubview(pinView)
            let rowsICanSee = tableView.indexPathsForVisibleRows() as [NSIndexPath] //Rows Seen
            let cellSelected = tableView.cellForRowAtIndexPath(selectedRow)
            if rowsICanSee.first == selectedRow || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
                pinView.backgroundColor = cellSelected!.backgroundColor
                if rowsICanSee.first == selectedRow {
                    pinView.center = CGPoint(x: view.center.x, y: 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                } else if rowsICanSee.last == selectedRow {
                    pinView.center = CGPoint(x: view.center.x, y: view.frame.height - 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                }
            }
            else {
                if selectedRow.compare(rowsICanSee.first!) != selectedRow.compare(rowsICanSee.last!) { //If they're equal then the thing is not on screen
                    pinView.center = CGPoint(x: cellSelected!.center.x, y: cellSelected!.center.y - tableView.contentOffset.y)
                    pinView.backgroundColor = cellSelected!.backgroundColor
                }
            }
        }
    }
}
