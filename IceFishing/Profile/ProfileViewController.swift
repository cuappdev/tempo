//
//  ProfileViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var otherUser: User!
    var isFollowing = false
    var numFollowing: Int = 0
    var searchNavigationController: UINavigationController!
    
    // Post History Calendar
    var collectionView : UICollectionView!
    var calendar : NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var startDate : NSDate! = NSDate(dateString:"2015-01-26")
    var currentDate : NSDate! = NSDate()
    // Hardcoded dates for testing
    var postedDates: [NSDate]! = [NSDate(dateString:"2015-05-04"), NSDate(dateString:"2015-05-03"), NSDate(dateString:"2015-05-02"), NSDate(dateString:"2015-05-01"), NSDate(dateString:"2015-04-30"), NSDate(dateString:"2015-04-29"), NSDate(dateString:"2015-04-28"), NSDate(dateString:"2015-04-27")]
    var daySize : CGSize!
    var padding : CGFloat = 5
    
    // Outlets
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var followButtonLabel: UIButton!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var postCalendarView: UIView!
    @IBOutlet weak var separator: UIView!

    func loadUserByID(id: String) {
        API.sharedAPI.fetchUser(id) { user in
            // Profile Info
            self.nameLabel.text = user.name
            self.userHandleLabel.text = "@\(user.username)"
            //self.profilePictureView.image = user.profileImage
            if let url = NSURL(string: "http://graph.facebook.com/\(user.fbid)/picture?type=large") {
                if let data = NSData(contentsOfURL: url) {
                    self.profilePictureView.image = UIImage(data: data)
                }
            }
            self.profilePictureView.layer.masksToBounds = false
            self.profilePictureView.layer.borderWidth = 1.5
            self.profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
            self.profilePictureView.frame = CGRectMake(0, 0, 150/2, 150/2)
            self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2
            self.profilePictureView.clipsToBounds = true
            
            // Followers & Following
            self.followButtonLabel.frame = CGRectMake(0, 0, 197/2, 59/2)
            self.numFollowersLabel.text = "\(user.followersCount)"
            self.numFollowingLabel.text = "\(self.numFollowing)"
            
            if !self.isFollowing {
                self.followButtonLabel.setTitle("FOLLOW", forState: .Normal)
            } else {
                self.followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
            }
            
            // User Creation Date
            var dateFormatter = NSDateFormatter()
            //!TODO: Make this a global date formatter
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
            var dateFromString = dateFormatter.dateFromString(User.currentUser.createdAt)
            //startDate = dateFromString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Uncomment when API done
        //        API.sharedAPI.fetchPosts(User.currentUser.id) { post in
        //            self.postedDates = post.date // dates user posted song
        //        }
        
        loadUserByID(otherUser.fbid)
        
        // Navigation Bar
        navigationItem.title = "Profile"
        self.navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Post History Calendar
        let cols : Int = 6
        let dayWidth = postCalendarView.frame.width/CGFloat(cols)
        let dayHeight = dayWidth
        daySize = CGSize(width: dayWidth, height: dayHeight)
        separator.backgroundColor = UIColor.iceDarkRed()
        
        let layout: HipStickyHeaderFlowLayout = HipStickyHeaderFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding*6, bottom: padding*2, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: postCalendarView.frame, collectionViewLayout: layout)
        collectionView.registerClass(HipCalendarCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.registerClass(HipCalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.allowsMultipleSelection = true
        collectionView.frame = CGRectMake(0, 0, postCalendarView.frame.width, postCalendarView.frame.height/2.25)
        postCalendarView.addSubview(collectionView)
        collectionView.scrollsToTop = false
        
        // Add back button
        self.navigationItem.hidesBackButton = true
        var backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height/2))
        backButton.setImage(UIImage(named: "LeftArrow"), forState: .Normal)
        backButton.addTarget(self, action: "popToPrevious", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        // Add return to profile button
        var profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        profileButton.setImage(UIImage(named: "Close-Icon"), forState: .Normal)
        profileButton.addTarget(self, action: "popToRoot", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }

    // Return to profile view
    func popToRoot() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Return to previous view
    func popToPrevious() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // <------------------------FOLLOW BUTTONS------------------------>
    
    @IBAction func followButton(sender: UIButton) {
        if (!isFollowing) {
            isFollowing = true
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
            User.currentUser.followersCount = User.currentUser.followersCount + 1
            // TODO: Update following
//            API.sharedAPI.updateFollowings(User.currentUser.id, unfollow: false) { bool in
//                println(bool)
//            }
        } else {
            isFollowing = false
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
            User.currentUser.followersCount = User.currentUser.followersCount - 1
            // TODO: Update following
//            API.sharedAPI.updateFollowings(User.currentUser.id, unfollow: true) { bool in
//                println(bool)
//            }
        }
        numFollowersLabel.text = "\(User.currentUser.followersCount)"
        println(User.currentUser.followers)
    }
    
    @IBAction func followersButton(sender: UIButton) {
        let followersVC = FollowersViewController(nibName: "FollowersViewController", bundle: nil)
        followersVC.title = "Followers"
        navigationController?.pushViewController(followersVC, animated: true)
    }

    @IBAction func followingButton(sender: UIButton) {
        let followingVC = FollowingViewController(nibName: "FollowingViewController", bundle: nil)
        followingVC.title = "Following"
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    // <------------------------POST HISTORY------------------------>
    
    // When post history label clicked
    @IBAction func scrollToTop(sender: UIButton) {
        collectionView.setContentOffset(CGPointZero, animated: true)
    }
    
    // Helper Methods
    private func dateForIndexPath(indexPath: NSIndexPath) -> NSDate {
        var date : NSDate! = currentDate?.dateByAddingMonths(-indexPath.section).lastDayOfMonth()
        let components : NSDateComponents = date.components()
        components.day = date.numDaysInMonth() - indexPath.item
        date = NSDate.dateFromComponents(components)
        return date;
    }
    
    // Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let date: NSDate = dateForIndexPath(indexPath)
        var cell : HipCalendarDayCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! HipCalendarDayCollectionViewCell
        cell.date = date
        cell.userInteractionEnabled = false

        if (contains(postedDates,cell.date)) {
            cell.dayInnerCircleView.backgroundColor = UIColor.iceDarkRed()
            cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    // Section Header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let firstDayOfMonth: NSDate = dateForIndexPath(indexPath).firstDayOfMonth()
            var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HipCalendarCollectionReusableView
            header.firstDayOfMonth = firstDayOfMonth
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var numberOfMonths : Int? = startDate?.numberOfMonths(self.currentDate!)
        println(numberOfMonths)
        return numberOfMonths == nil ? 0 : numberOfMonths!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDayOfMonth : NSDate? = currentDate?.firstDayOfMonth().dateByAddingMonths(-section)
        var numberOfDays : Int? = firstDayOfMonth?.numDaysInMonth()
        numberOfDays == nil ? 0 : numberOfDays!
        println(firstDayOfMonth)
        
        if (firstDayOfMonth!.month() == startDate.month() && firstDayOfMonth!.year() == startDate.year()) {
            numberOfDays = startDate.numDaysUntilEndDate(firstDayOfMonth!.lastDayOfMonth())
        }
        println(numberOfDays)
        
        return numberOfDays!
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let date: NSDate = dateForIndexPath(indexPath)
        let index = find(postedDates, date) as Int?
        
        // Push to TableView with posted songs and dates
        let postHistoryVC = PostHistoryTableViewController(nibName: "PostHistoryTableViewController", bundle: nil)
        postHistoryVC.postedDates = postedDates
        postHistoryVC.selectedDate = date
        postHistoryVC.index = index!
        navigationController?.pushViewController(postHistoryVC, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.width - padding * 2, 30)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return daySize
    }
    
}

