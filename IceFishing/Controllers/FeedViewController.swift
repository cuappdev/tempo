//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var currentlyPlayingCell: FeedTableViewCell?
    var feedTableView = UITableView()
    var pinView: UIView = UIView()
    
    var testSongIDs: [String] = [
        "https://p.scdn.co/mp3-preview/8b545950a285e9f715e783a197faf6c6bcf6b724",
        "https://p.scdn.co/mp3-preview/4b75d979f23cb63e2b6c48c98a7706f2735ef15a",
        "https://p.scdn.co/mp3-preview/342d48054332f1cd5d7fe4f30f6856faf07c1e48",
        "https://p.scdn.co/mp3-preview/23fa9ad27d22e18fde8ec02eec82b67a3422978f",
        "https://p.scdn.co/mp3-preview/088f11ec4b7d500586ada02ab99965c681a30e3e",
        "https://p.scdn.co/mp3-preview/1587652c5763e83fc594a92468b635fbc2d305cb",
        "https://p.scdn.co/mp3-preview/5ddbf8791851f6d12e8f2348ff3f85f4cad54c26"]
    var testSongDescriptions: [String] = [
        "Under the Same Sun - Ben Howard",
        "1985 - Passion Pit",
        "Angel - Shaggy",
        "Rather Be - Clean Bandit feat. Jesse Glynn",
        "Talking Body - Gryffin Remix - Tove Lo",
        "Cheerleader - Felix Jaehn Remix Radio Edit - Omi",
        "Gold Rush - Deluxe Edition - Ed Sheeran"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .None
        
        feedTableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        feedTableView.frame = view.bounds
        view.addSubview(feedTableView)
        
        pinView.frame = CGRectMake(0, 0, view.frame.width, 100)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let topInset = navigationController?.navigationBar.frame.maxY {
            feedTableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testSongIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as FeedTableViewCell
        
        cell.songID = NSURL(string: testSongIDs[indexPath.row])
        cell.player = Player(fileURL: cell.songID)
        
        /* Hot fix for song name going out of bounds, would be great to make scrolling on play.
            Currently counts based on number of characters not their pixel size i.e. "..." is smaller than "www"
            -Steven Yeh - say25
        */
        if (testSongDescriptions[indexPath.row].utf16Count >= 45){
            let index: String.Index = advance(testSongDescriptions[indexPath.row].startIndex, 41)
            cell.songDescriptionLabel.text = testSongDescriptions[indexPath.row].substringToIndex(index) + "..."
        }
        else {
            cell.songDescriptionLabel.text = testSongDescriptions[indexPath.row]
        }
        
        cell.songPostTimeLabel.text = String(indexPath.row+1) + " min"
        
        if indexPath.item == 3 || indexPath.item == 5 || indexPath.item == 0 {
            cell.avatarImageView.image = UIImage(named: "Eric")
            cell.profileNameLabel.text = "ERIC APPEL"
        } else {
            cell.avatarImageView.image = UIImage(named: "Sexy")
        }
                
        cell.callBack = {
            [unowned self]
            (isPlaying, sender) in
            
            if (isPlaying) {
                
                if (self.currentlyPlayingCell != sender) {
                    self.currentlyPlayingCell?.player.pause()
                }
                self.currentlyPlayingCell = sender;
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.0;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (feedTableView.indexPathForSelectedRow() != nil){ //If a row is selected
            view.addSubview(pinView)
            //println("lol")
            var selectedRow = feedTableView.indexPathForSelectedRow()! //Selected Row
            var rowsICanSee = feedTableView.indexPathsForVisibleRows()! //Rows Seen
            var cellSelected = feedTableView.cellForRowAtIndexPath(selectedRow)
            if(rowsICanSee[0] as NSObject == selectedRow || rowsICanSee[rowsICanSee.count-1] as NSObject == selectedRow) { //If the cell is the top or bottom
                pinView.backgroundColor = cellSelected!.backgroundColor
                if(rowsICanSee[0] as NSObject == selectedRow){
                    pinView.center = CGPoint(x: view.center.x, y: 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                } else if (rowsICanSee[rowsICanSee.count-1] as NSObject == selectedRow){
                    pinView.center = CGPoint(x: view.center.x, y: view.frame.height - 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                }
                
            }
                
            else {
                if(selectedRow.compare(rowsICanSee[0] as NSIndexPath) != selectedRow.compare(rowsICanSee[rowsICanSee.count-1] as NSIndexPath)) { //If they're equal then the thing is not on screen
                    pinView.center = CGPoint(x: cellSelected!.center.x, y: cellSelected!.center.y - feedTableView.contentOffset.y)
                    pinView.backgroundColor = cellSelected!.backgroundColor
                }
            }
        }
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (feedTableView.indexPathForSelectedRow() != nil){ //If a row is selected
            view.addSubview(pinView)
            //println("Lol 2")
            var selectedRow = feedTableView.indexPathForSelectedRow()! //Selected Row
            var rowsICanSee = feedTableView.indexPathsForVisibleRows()! //Rows Seen
            var cellSelected = feedTableView.cellForRowAtIndexPath(selectedRow)
            if(rowsICanSee[0] as NSObject == selectedRow || rowsICanSee[rowsICanSee.count-1] as NSObject == selectedRow) { //If the cell is the top or bottom
                pinView.backgroundColor = cellSelected!.backgroundColor
                if(rowsICanSee[0] as NSObject == selectedRow){
                    pinView.center = CGPoint(x: view.center.x, y: 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                } else if (rowsICanSee[rowsICanSee.count-1] as NSObject == selectedRow){
                    pinView.center = CGPoint(x: view.center.x, y: view.frame.height - 50)
                    pinView.removeFromSuperview()
                    view.addSubview(pinView)
                }
            }
                
            else {
                if(selectedRow.compare(rowsICanSee[0] as NSIndexPath) != selectedRow.compare(rowsICanSee[rowsICanSee.count-1] as NSIndexPath)) { //If they're equal then the thing is not on screen
                    pinView.center = CGPoint(x: cellSelected!.center.x, y: cellSelected!.center.y - feedTableView.contentOffset.y)
                    pinView.backgroundColor = cellSelected!.backgroundColor
                }
            }
        }
    }
}
