//
//  SideBarViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SideBarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBLoginViewDelegate {
    
    var categories: [String] = ["Feed", "People", "Liked", "Spotify"]
    var symbols: [String] = ["Gray-Feed-Icon", "People-Icon", "Liked-Icon", "Music-Icon"]

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBAction func logOut(sender: UIButton) {
        FBSession.activeSession().closeAndClearTokenInformation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = UIImage(named: "Sexy")
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.frame = CGRectMake(0, 0, 85, 85)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
        profilePicture.clipsToBounds = true

        categoryTableView.registerNib(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! SideBarTableViewCell
        
        cell.categorySymbol.image = UIImage(named: self.symbols[indexPath.row])
        cell.categoryLabel.text = self.categories[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(55)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 43/255, green: 73/255, blue: 90/255, alpha: 1)
        
        if (indexPath.row == 0) {
//            let feedVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
//            presentViewController(feedVC, animated: false, completion: nil)
        } else if (indexPath.row == 1) {
            
        } else if (indexPath.row == 2) {
            
        } else {
            
        }
        
    }

}
