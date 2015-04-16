//
//  FollowersViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        // Custom initialization
//        println("initialized")
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    var tableView: UITableView = UITableView()
    var followersPics: [String]!
    var followers: [String] = ["Adam", "Adler", "Alexander", "Andrew", "Annie", "Ashton", "Austin", "Brendan", "Brian", "Dennis"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        tableView.backgroundColor = UIColor(red: 48/255, green: 84/255, blue: 110/255, alpha: 1)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerNib(UINib(nibName: "CustomOneCell", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        self.view.addSubview(tableView)
        
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: navigationController!.navigationBar.frame.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 181/255, green: 87/255, blue: 78/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = self.followers[indexPath.row]
        cell.detailTextLabel?.text = "@username"
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor(red: 48/255, green: 84/255, blue: 110/255, alpha: 1)
        
        //cell.imageView?.image = followersPics[indexPath.row]
        cell.imageView?.image = UIImage(named: "Sexy")
        cell.imageView?.layer.masksToBounds = false
        cell.imageView?.layer.borderWidth = 1.5
        cell.imageView?.layer.borderColor = UIColor.whiteColor().CGColor
        cell.imageView?.frame = CGRectMake(0, 0, 20, 20)
        cell.imageView?.layer.cornerRadius = 50
        cell.imageView?.clipsToBounds = true
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(followers[indexPath.row])")
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 19/255, green: 39/255, blue: 49/255, alpha: 1)
    }
    
}