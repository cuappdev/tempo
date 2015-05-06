//
//  LoginViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var isFollowing = false
    var numFollowing: Int = 0
    var searchNavigationController: UINavigationController!
    
    // Post History Calendar
    var collectionView : UICollectionView!
    var calendar : NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var startDate : NSDate! = NSDate(dateString:"2015-01-05")
    var currentDate : NSDate! = NSDate()
    // Hardcoded dates for testing
    var postedDates: [NSDate]! = [NSDate(dateString:"2015-04-24"), NSDate(dateString:"2015-04-22"), NSDate(dateString:"2015-04-18"), NSDate(dateString:"2015-04-15"), NSDate(dateString:"2015-04-11"), NSDate(dateString:"2015-04-9"), NSDate(dateString:"2015-04-08"), NSDate(dateString:"2015-04-07")]
    var daySize : CGSize!
    var padding : CGFloat = 5
    
    // Outlets
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UIButton!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var postCalendarView: UIView!
    @IBOutlet weak var separator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Uncomment when API done
        //        API.sharedAPI.fetchPosts(User.currentUser.id) { post in
        //            self.postedDates = post.date // dates user posted song
        //        }
        
        // Profile Info
        let user = User.currentUser
        self.nameLabel.text = user.name
        self.userHandleLabel.setTitle("@\(user.username)", forState: UIControlState.Normal)
        user.loadImage {
            self.profilePictureView.image = $0
        }
        
        self.profilePictureView.layer.masksToBounds = false
        self.profilePictureView.layer.borderWidth = 1.5
        self.profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profilePictureView.frame = CGRectMake(0, 0, 150/2, 150/2)
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2
        self.profilePictureView.clipsToBounds = true
        
        // Followers & Following
//        self.numFollowersLabel.text = "\(User.currentUser.followersCount)"
//        self.numFollowingLabel.text = "\(self.numFollowing)"
        self.numFollowersLabel.text = "5"
        self.numFollowingLabel.text = "2"
        
        // User Creation Date
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        var dateFromString = dateFormatter.dateFromString(User.currentUser.createdAt)
        //startDate = dateFromString
        
        // Navigation Bar
        self.title = "Profile"
        beginIceFishing()
        
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
    }
    
    func dismiss(sender: AnyObject?) {
        self.revealViewController()?.revealToggle(sender)
    }
    
    // When username on profile screen clicked
    @IBAction func changeUserHandle(sender: UIButton) {
        var editAlert = UIAlertController(title: "Edit Username", message: "This is how you appear to other users.", preferredStyle: UIAlertControllerStyle.Alert)
        editAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        editAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "New username"
            textField.textAlignment = NSTextAlignment.Center
        }
        editAlert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) {action -> Void in
            
            let textField = editAlert.textFields?.first as? UITextField
            let newUsername = textField!.text
            
            API.sharedAPI.usernameIsValid(newUsername) { success in
                if (success) {
                    if (newUsername == "") {
                        var alert = UIAlertController(title: "Oh no!", message: "Username cannot be empty.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        User.currentUser.username = newUsername
                        API.sharedAPI.updateCurrentUser(newUsername) { user in }
                        self.userHandleLabel.setTitle("@\(User.currentUser.username)", forState: UIControlState.Normal)
                    }
                } else {
                    var alert = UIAlertController(title: "Sorry!", message: "Username is taken.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
        self.presentViewController(editAlert, animated: true, completion: nil)
    }

    // <------------------------FOLLOW BUTTONS------------------------>
    
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

