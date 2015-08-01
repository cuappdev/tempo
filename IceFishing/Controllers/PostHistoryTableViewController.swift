//
//  PostHistoryTableViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class PostHistoryTableViewController: UITableViewController, UIScrollViewDelegate {
    
    var songPictures: [String]! = []
    var songArtists: [String]! = []
    var songNames: [String]! = []
    var postedDates: [NSDate]! = []
    var index: Int = 0
    var selectedDate: NSDate!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.iceDarkGray
        tableView.registerNib(UINib(nibName: "PostHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedSongCell")
        
        navigationItem.title = "Post History"
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add back button to profile
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height))
        backButton.setImage(UIImage(named: "Close-Icon"), forState: .Normal)
        backButton.addTarget(self, action: "popToPrevious", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        let selectedRow: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.selectRowAtIndexPath(selectedRow, animated: true, scrollPosition: UITableViewScrollPosition.Top)
    }
    
    // Return to profile view
    func popToPrevious() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postedDates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostedSongCell", forIndexPath: indexPath) as! PostHistoryTableViewCell
        
        // TODO: For testing purposes (delete when test user is made)
        cell.postedSongImage.image = UIImage(named: "Sexy")
        cell.artistNameLabel.text = "John Legend"
        cell.songNameLabel.text = "All Of Me"
        cell.numLikesLabel.text = "10 Likes"
        
        // TODO: Uncomment when test user is made
        // cell.artistNameLabel.text = self.songArtists[indexPath.row]
        // cell.songNameLabel.text = self.songNames[indexPath.row]
        // cell.postedSongImage.image = UIImage(named: "self.songPictures[indexPath.row]")
        
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "M.dd.YY"
        let date: String = formatter.stringFromDate(self.postedDates[indexPath.row])
        cell.datePostedLabel.text = "\(date)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray
    }
    
}
