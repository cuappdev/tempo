//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

var addedSongs = 0
class FeedViewController: UITableViewController, UIScrollViewDelegate {
    var pinView: UIView = UIView()
    var posts: [Post] = []
    var currentlyPlayingIndexPath: NSIndexPath?
    var topPinViewContainer = UIView()
    var bottomPinViewContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(NSDate())")
        
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        var post = Post(song: Song(songID: "3TV9xKWFOxndERab4wwxsj"), posterFirst: "Mark", posterLast: "Bryan", date: NSDate(), avatar: UIImage(named: "Sexy"))
        posts.append(post)
        post = Post(song: Song(songID: "3igu6bCzkaIrioZIhK3p2n"), posterFirst: "Eric", posterLast: "Appel", date: NSDate(), avatar: UIImage(named: "Eric"))
        posts.append(post)
        post = Post(song: Song(songID: "4RY96Asd9IefaL3X4LOLZ8"), posterFirst: "Steven", posterLast: "Yeh", date: NSDate(), avatar: UIImage(named: "Steven"))
        posts.append(post)
        
        self.tableView.backgroundColor = UIColor(red: CGFloat(43.0/255.0), green: CGFloat(73.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        self.tableView.separatorColor = UIColor(red: CGFloat(19.0/255.0), green: CGFloat(39.0/255.0), blue: CGFloat(49.0/255.0), alpha: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        topPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 128)
        topPinViewContainer.center = CGPoint(x: view.center.x, y: navigationController!.navigationBar.frame.maxY + 64)
        parentViewController!.view.addSubview(topPinViewContainer)
        bottomPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 128)
        bottomPinViewContainer.center = CGPoint(x: view.center.x, y: view.frame.height - 64)
        parentViewController!.view.addSubview(bottomPinViewContainer)
        
        
        //XXX: @pastachan: without this we don't receive touches to the first and last items
        // I suggest hiding them when they are not in use so touch events get passed along to the
        // table view
        topPinViewContainer.hidden = true
        bottomPinViewContainer.hidden = true
        
        println(topPinViewContainer.center)
        println(bottomPinViewContainer.center)
    }
    
    //Mark: - UIRefreshControl
    func refreshFeed() {
//        testSongIDs.append("https://p.scdn.co/mp3-preview/dba0ce6ac6310d7be00545861f9b58aeb86930a3")
//        testSongDescriptions.append("Don't Stop the Party - Pitbull")
        var post: Post?
        switch (addedSongs) {
        case 0:
            post = Post(song: Song(songID: "0fgZUSa7D7aVvv3GfO0A1n"), posterFirst: "Eric", posterLast: "Appel", date: NSDate(), avatar: UIImage(named: "Eric"))
            break
        case 1:
            post = Post(song: Song(songID: "5dANgSy7v091dhiPnEXNrf"), posterFirst: "Steven", posterLast: "Yeh", date: NSDate(), avatar: UIImage(named: "Steven"))
            break
        case 2:
            post = Post(song: Song(songID: "4wQrzVXnhslsVY5lZSJjHG"), posterFirst: "Mark", posterLast: "Bryan", date: NSDate(), avatar: UIImage(named: "Sexy"))
            break
        default:
            post = Post(song: Song(songID: "0nmxH6IsSQVT1YEsCB9UMi"), posterFirst: "Steven", posterLast: "Yeh", date: NSDate(), avatar: UIImage(named: "Steven"))
            break
        }
        
        posts.append(post!)
        addedSongs++
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
            if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
                posts[currentlyPlayingIndexPath.row].player.pause()
            }
            posts[indexPath.row].player.play()
        }
        currentlyPlayingIndexPath = indexPath
        
        println("This has run")
        
        //XXX: Remove this return statement when you fix this
        return;
        if let selectedRow = tableView.indexPathForSelectedRow() { //If a row is selected
            let rowsICanSee = tableView.indexPathsForVisibleRows() as [NSIndexPath] //Rows Seen
            let cellSelected = tableView.cellForRowAtIndexPath(selectedRow)
            if cellSelected!.frame.minY - tableView.contentOffset.y <= navigationController!.navigationBar.frame.maxY || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
                println("here")
                pinView.backgroundColor = UIColor.blueColor()
                if (cellSelected!.frame.minY - tableView.contentOffset.y <= navigationController!.navigationBar.frame.maxY) {
                    println("Here too")
                    pinView.removeFromSuperview()
                    pinView.frame = topPinViewContainer.bounds
                    topPinViewContainer.addSubview(pinView)
                    pinView.backgroundColor = UIColor.redColor()
                } else if rowsICanSee.last == selectedRow {
                    println("Hey")
                    pinView.removeFromSuperview()
                    pinView.frame = bottomPinViewContainer.bounds
                    bottomPinViewContainer.addSubview(pinView)
                    pinView.backgroundColor = UIColor.redColor()
                }
            }
            else {
                if selectedRow.compare(rowsICanSee.first!) != selectedRow.compare(rowsICanSee.last!) { //If they're equal then the thing is not on screen
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                    println("LOLOLOL")
                    pinView.center = CGPoint(x: cellSelected!.center.x, y: cellSelected!.center.y)
                    pinView.backgroundColor = UIColor.blueColor()
                }
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //XXX: This crashes
        return;
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
