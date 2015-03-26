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
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as FeedTableViewCell
        if indexPath.row == 0 {
            // Angel - Shaggy
            cell.songID = NSURL(string: "https://p.scdn.co/mp3-preview/342d48054332f1cd5d7fe4f30f6856faf07c1e48")
            cell.player = Player(fileURL: cell.songID)
            cell.songDescriptionLabel.text = "Angel - Shaggy"
        } else if indexPath.row == 1 {
            // Rather Be - Clean Bandit
            cell.songID = NSURL(string: "https://p.scdn.co/mp3-preview/23fa9ad27d22e18fde8ec02eec82b67a3422978f")
            cell.player = Player(fileURL: cell.songID)
            cell.songDescriptionLabel.text = "Rather Be - Clean Bandit feat. Jesse Glynn"
        }
        
        cell.avatarImageView.image = UIImage(named: "Sexy")
        
        cell.callBack = {
            [unowned self]
            (isPlaying, sender) in
            
            if (isPlaying) {
                
                self.currentlyPlayingCell?.player.pause()
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
