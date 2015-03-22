//
//  TrendingVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class TrendingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var trendingTableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trendingTableView.delegate = self
        trendingTableView.dataSource = self
        trendingTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        //trendingTableView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(trendingTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? UITableViewCell
        if !(cell != nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
        }
        
        cell?.textLabel.text = "Tropical Avocado Symphony (Trending)"
        
        
        return cell! as UITableViewCell
    }
    

}
