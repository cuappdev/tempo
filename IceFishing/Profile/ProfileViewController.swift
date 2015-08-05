//
//  ProfileViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var user: User!
    var isFollowing = false
    var numFollowing: Int = 0
    var searchNavigationController: UINavigationController!
    
    // Post History Calendar
    var calendar : NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var startDate = NSDate(dateString:"2015-01-26")
    // Hardcoded dates for testing
    var postedDates: [NSDate]! = [NSDate(dateString:"2015-04-20"), NSDate(dateString:"2015-04-17"), NSDate(dateString:"2015-04-26"), NSDate(dateString:"2015-04-23"), NSDate(dateString:"2015-04-19"), NSDate(dateString:"2015-04-15"), NSDate(dateString:"2015-04-08"), NSDate(dateString:"2015-04-07")]
    var padding : CGFloat = 5
    
    // Outlets
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var followButtonLabel: UIButton!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var separator: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Uncomment when API done
        //        API.sharedAPI.fetchPosts(User.currentUser.id) { post in
        //            postedDates = post.date // dates user posted song
        //        }
        
        // Profile Info
		title = "Profile"
		beginIceFishing()
		
        nameLabel.text = user.name
        userHandleLabel.text = "@\(user.username)"
        user.loadImage {
            self.profilePictureView.image = $0
        }
        profilePictureView.layer.borderWidth = 1.5
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true
        
        // Followers & Following
        followButtonLabel.setTitle("\(user.followersCount)", forState: .Normal)
		
        if !isFollowing {
            followButtonLabel.setTitle("FOLLOW", forState: .Normal)
        } else {
            followButtonLabel.setTitle("FOLLOWING", forState: .Normal)
        }
		
		// Post History Calendar
        separator.backgroundColor = UIColor.iceDarkRed
        
        let layout = collectionView.collectionViewLayout as! HipStickyHeaderFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding*6, bottom: padding*2, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
		
        collectionView.registerClass(HipCalendarCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.registerClass(HipCalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.backgroundColor = UIColor.clearColor()
		collectionView.scrollsToTop = false
		
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close-Icon"), style: .Plain, target: self, action: "popToRoot")
		
		let views: [String : AnyObject] = ["pic" : profilePictureView, "topGuide": self.topLayoutGuide]
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-[pic]", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views))
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
//        numFollowersLabel.text = "\(User.currentUser.followersCount)"
        print(User.currentUser.followers)
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
        let date = NSDate().dateByAddingMonths(-indexPath.section).lastDayOfMonth()
        let components : NSDateComponents = date.components()
        components.day = date.numDaysInMonth() - indexPath.item
        return NSDate.dateFromComponents(components)
    }
    
    // Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let date = dateForIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! HipCalendarDayCollectionViewCell
        cell.date = date
        cell.userInteractionEnabled = false

        if (postedDates.contains(cell.date)) {
            cell.dayInnerCircleView.backgroundColor = UIColor.iceDarkRed
			cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    // Section Header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let firstDayOfMonth = dateForIndexPath(indexPath).firstDayOfMonth()
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HipCalendarCollectionReusableView
            header.firstDayOfMonth = firstDayOfMonth
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return startDate.numberOfMonths(NSDate())
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDayOfMonth = NSDate().firstDayOfMonth().dateByAddingMonths(-section)
        var numberOfDays = firstDayOfMonth.numDaysInMonth()
        
        if (firstDayOfMonth.month() == startDate.month() && firstDayOfMonth.year() == startDate.year()) {
            numberOfDays = startDate.numDaysUntilEndDate(firstDayOfMonth.lastDayOfMonth())
        }
        
        return numberOfDays
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let date = dateForIndexPath(indexPath)
        let index = postedDates.indexOf(date) as Int?
        
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
		let cols: CGFloat = 6
		let dayWidth = collectionView.frame.width / cols
		let dayHeight = dayWidth
        return CGSize(width: dayWidth, height: dayHeight)
    }
    
}

