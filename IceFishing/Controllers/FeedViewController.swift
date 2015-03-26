//
//  FeedVC.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/15/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentlyPlayingCell: FeedTableViewCell?
    var feedTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .None
        
        feedTableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        feedTableView.frame = view.bounds
        view.addSubview(feedTableView)
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
    
}
