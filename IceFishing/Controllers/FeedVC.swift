//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var feedTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.frame = CGRect(x: 0, y: 0, width: view.center.x*2, height: view.center.y*2)
        //feedTableView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(feedTableView)
        //feedTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: feedTableView.frame.width, height: 100))
        //feedTableView.tableHeaderView?.backgroundColor = UIColor.blueColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var returnCell: FeedTableViewCell
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("id") as? FeedTableViewCell {
            returnCell = cell
        } else {
            
            returnCell = FeedTableViewCell(style: .Default, reuseIdentifier: "id")
            returnCell.frame = CGRectMake(0, 0, self.view.frame.width, 100)
            returnCell.setUpCell("Avocados", songArtist: "Jimmy", songImage: UIImage(named: "Avocados")!, shareTime: "shared 3 minutes ago", userWhoSharedThis: "Big Bob")
            let red = CGFloat(CGFloat(arc4random() % 255) / 255.0)
            returnCell.backgroundColor = UIColor(red: red, green: 0.5, blue: 0.5, alpha: 1.0)
            
        }
        
        return returnCell
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 
    }
    
}
