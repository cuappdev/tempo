//
//  TrendingVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class TrendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var trendingTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trendingTableView.delegate = self
        trendingTableView.dataSource = self
        
        trendingTableView.frame = view.bounds
        view.addSubview(trendingTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let topInset = navigationController?.navigationBar.frame.maxY {
            trendingTableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
        }
        
        cell?.textLabel.text = "Tropical Avocado Symphony (Trending)"
        
        return cell! as UITableViewCell
    }
}
