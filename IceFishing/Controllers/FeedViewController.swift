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
    var posts: [Post] = []
    var currentlyPlayingIndexPath: NSIndexPath?
    var topPinViewContainer: UIView = UIView()
    var bottomPinViewContainer: UIView = UIView()
    @IBOutlet var pinView: PostView!
    var pinViewGestureRecognizer: UITapGestureRecognizer!
    
    func addSong(track: TrackResult) {
        posts.append(Post(trackResult: track,
            posterFirst: "Mark",
            posterLast: "Bryan",
            date: NSDate(),
            avatar: UIImage(named: "Sexy")))
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(NSDate())", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        
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
        pinViewGestureRecognizer = UITapGestureRecognizer(target: self, action: "togglePlay")
        pinViewGestureRecognizer.delegate = pinView
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        topPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 96.0)
        topPinViewContainer.center = CGPoint(x: view.center.x, y: navigationController!.navigationBar.frame.maxY + 48)
        parentViewController!.view.addSubview(topPinViewContainer)
        bottomPinViewContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 96.0)
        bottomPinViewContainer.center = CGPoint(x: view.center.x, y: view.frame.height - 48)
        parentViewController!.view.addSubview(bottomPinViewContainer)
        
        topPinViewContainer.hidden = true
        bottomPinViewContainer.hidden = true
        
        pinView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 96.0)
        
        
        
        //XXX: @pastachan: without this we don't receive touches to the first and last items
        // I suggest hiding them when they are not in use so touch events get passed along to the
        // table view
    }
    
    func togglePlay() {
        println("here tho")
        pinView.post?.player.togglePlaying()
    }
    
    //MARK: - UIRefreshControl
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
        cell.postView.post?.player.prepareToPlay()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.isEqual(currentlyPlayingIndexPath)) { // Same index path tapped
            posts[indexPath.row].player.togglePlaying()
        } else { // Different cell tapped
            if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
                posts[currentlyPlayingIndexPath.row].player.pause(true)
                posts[currentlyPlayingIndexPath.row].player.progress = 1.0 // Fill cell as played
                
            }
            posts[indexPath.row].player.play(true)
        }
        
        currentlyPlayingIndexPath = indexPath
        println("This has run")
        //XXX: Remove this return statement when you fix this
        //return;
        cellPin()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //XXX: This crashes
        //return;
        cellPin()
    }
    
    func cellPin() {
        if let selectedRow = currentlyPlayingIndexPath { //If a row is selected
            let rowsICanSee = tableView.indexPathsForVisibleRows() as [NSIndexPath] //Rows Seen
            if let cellSelected = tableView.cellForRowAtIndexPath(selectedRow) as? FeedTableViewCell {
                if cellSelected.frame.minY - tableView.contentOffset.y <= navigationController!.navigationBar.frame.maxY || rowsICanSee.last == selectedRow { //If the cell is the top or bottom
                    println("here")
                    if (cellSelected.frame.minY - tableView.contentOffset.y <= navigationController!.navigationBar.frame.maxY) {
                        println("Here too")
                        pinView.post = posts[selectedRow.row]
                        pinView.layoutIfNeeded()
                        topPinViewContainer.addSubview(pinView)
                        pinView.addGestureRecognizer(pinViewGestureRecognizer)
                        topPinViewContainer.hidden = false
                        
                    } else if (cellSelected.frame.maxY - tableView.contentOffset.y >= parentViewController!.view.frame.height) {
                        println("Hey")
                        pinView.post = posts[selectedRow.row]
                        pinView.layoutIfNeeded()
                        bottomPinViewContainer.addSubview(pinView)
                        pinView.addGestureRecognizer(pinViewGestureRecognizer)
                        bottomPinViewContainer.hidden = false
                        
                    }
                    
                }
                else {
                    if selectedRow.compare(rowsICanSee.first!) != selectedRow.compare(rowsICanSee.last!) { //If they're equal then the thing is not on screen
                        topPinViewContainer.hidden = true
                        bottomPinViewContainer.hidden = true
                        pinView.post = nil
                        pinView.removeFromSuperview()
                    }
                }
            }
        }
        
    }
}
