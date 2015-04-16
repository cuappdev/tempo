//
//  TrendingVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class TrendingViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var refreshControler = UIRefreshControl()
        
        self.refreshControl = refreshControler
        self.refreshControl?.addTarget(self, action: "didRefreshTrending", forControlEvents: .ValueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString (string: "Last Updated on \(NSDate())")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let topInset = navigationController?.navigationBar.frame.height {
            tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, 0, 0)
        }
    }
    
    //MARK: - UIRefreshControl
    
    func didRefreshTrending() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
        }
        
        cell?.textLabel.text = "Tropical Avocado Symphony (Trending)"
        
        return cell! as UITableViewCell
    }
}
