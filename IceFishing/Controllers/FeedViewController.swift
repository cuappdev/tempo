//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController, UIScrollViewDelegate {
    var currentlyPlayingCell: FeedTableViewCell?
    var pinView: UIView = UIView()

    var testSongIDs = [
        "https://p.scdn.co/mp3-preview/8b545950a285e9f715e783a197faf6c6bcf6b724",
        "https://p.scdn.co/mp3-preview/4b75d979f23cb63e2b6c48c98a7706f2735ef15a",
        "https://p.scdn.co/mp3-preview/342d48054332f1cd5d7fe4f30f6856faf07c1e48",
        "https://p.scdn.co/mp3-preview/23fa9ad27d22e18fde8ec02eec82b67a3422978f",
        "https://p.scdn.co/mp3-preview/088f11ec4b7d500586ada02ab99965c681a30e3e",
        "https://p.scdn.co/mp3-preview/1587652c5763e83fc594a92468b635fbc2d305cb",
        "https://p.scdn.co/mp3-preview/5ddbf8791851f6d12e8f2348ff3f85f4cad54c26"]
    
    var testSongDescriptions = [
        "Under the Same Sun - Ben Howard",
        "1985 - Passion Pit",
        "Angel - Shaggy",
        "Rather Be - Clean Bandit feat. Jesse Glynn",
        "Talking Body - Gryffin Remix - Tove Lo",
        "Cheerleader - Felix Jaehn Remix Radio Edit - Omi",
        "Gold Rush - Deluxe Edition - Ed Sheeran"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshFeed", forControlEvents: .ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(NSDate())")
        
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
    }
    
    //Mark: - UIRefreshControl
    
    func refreshFeed() {
        testSongIDs.append("https://p.scdn.co/mp3-preview/dba0ce6ac6310d7be00545861f9b58aeb86930a3")
        testSongDescriptions.append("Don't Stop the Party - Pitbull")

        self.tableView.reloadData()
        
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testSongIDs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as FeedTableViewCell
        
        cell.songID = NSURL(string: testSongIDs[indexPath.row])
        cell.player = Player(fileURL: cell.songID)
        cell.songDescriptionLabel.text = testSongDescriptions[indexPath.row]
        cell.songPostTimeLabel.text = String(indexPath.row+1) + " min"
        
        if indexPath.item == 3 || indexPath.item == 5 || indexPath.item == 0 {
            cell.avatarImageView.image = UIImage(named: "Eric")
            cell.profileNameLabel.text = "ERIC APPEL"
        } else if indexPath.item > 6 {
            cell.avatarImageView.image = UIImage(named: "Steven")
            cell.profileNameLabel.text = "STEVEN YEH"
        }
        else {
            cell.avatarImageView.image = UIImage(named: "Sexy")
        }
                
        cell.callBack = {
            [unowned self]
            (isPlaying, sender) in
            
            if isPlaying {
                
                if (self.currentlyPlayingCell != sender) {
                    self.currentlyPlayingCell?.player.pause()
                }
                self.currentlyPlayingCell = sender;
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.0;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
