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
    var index: Int!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        println(postedDates)
        
        tableView.backgroundColor = UIColor.iceDarkGray()
        tableView.registerNib(UINib(nibName: "PostHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PostedSongCell")
        
        tableView.separatorStyle = .None
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Add back button to profile
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        backButton.setImage(UIImage(named: "Profile-Icon"), forState: .Normal)
        backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // Return to profile view
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TableView Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postedDates.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostedSongCell", forIndexPath: indexPath) as! PostHistoryTableViewCell
        
//        cell.artistNameLabel.text = self.songArtists[indexPath.row]
//        cell.songNameLabel.text = self.songNames[indexPath.row]
        
        cell.postedSongImage.image = UIImage(named: "Sexy")
        cell.artistNameLabel.text = "John Legend"
        cell.songNameLabel.text = "All Of Me"
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-YY"
        let date: String = formatter.stringFromDate(self.postedDates[indexPath.row])
        cell.datePostedLabel.text = "Date Posted: \(date)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.iceLightGray()
    }
    
}
