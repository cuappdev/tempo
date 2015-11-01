//
//  ProfileViewController.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var user: User = User.currentUser
    var isFollowing = false
    
    // Post History Calendar
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    var startDate = NSDate(dateString:"2015-01-26")
	var posts: [Post] = []
    var postedDates: [NSDate] = []
	var postedDays: [Int] = []
	var postedLikes: [Int] = []
	var earliestPostDate: NSDate?
    var padding: CGFloat = 5
	var avgLikes: Float = 0
    
    // Outlets
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var followersButton: UIButton!
	@IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var separator: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		API.sharedAPI.fetchPosts(self.user.id) { post in
			self.posts = post
			self.postedDates = post.map { $0.date! }
			self.postedDays = self.postedDates.map { $0.day() }
			self.postedLikes = post.map{ $0.likes }
			self.collectionView.reloadData()
			for date in self.postedDates {
				if self.earliestPostDate == nil || date < self.earliestPostDate {
					self.earliestPostDate = date
				}
			}
			for likes in self.postedLikes {
				self.avgLikes += Float(likes)
			}
			self.avgLikes /= Float(self.postedLikes.count)
		}
		
        // Profile Info
		title = "Profile"
		if user == User.currentUser {
			addHamburgerMenu()
		}
		addRevealGesture()
		
        nameLabel.text = user.name
        userHandleLabel.text = "@\(user.username)"
        user.loadImage {
            self.profilePictureView.image = $0
        }
        profilePictureView.layer.borderWidth = 1.5
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true
		
		followButton.setTitle(isFollowing ? "FOLLOWING" : "FOLLOW", forState: .Normal)
		
        if User.currentUser.username == user.username {
            followButton.hidden = true
		}
		
		followingButton.setTitle("\(user.followingCount) Following", forState: .Normal)
		followersButton.setTitle("\(user.followersCount) Followers", forState: .Normal)
		
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
		
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close-Icon"), style: .Plain, target: self, action: "popToRoot")
		
		let views: [String : AnyObject] = ["pic" : profilePictureView, "topGuide": self.topLayoutGuide]
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-[pic]", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views))
		
		// Accounts for case where we select user from feed image
		if user.followersCount == 0 {
			API.sharedAPI.fetchUser(user.id) {
				self.user = $0
				self.followingButton.setTitle("\($0.followingCount) Following", forState: .Normal)
				self.followersButton.setTitle("\($0.followersCount) Followers", forState: .Normal)
			}
		}
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
	
	// TODO: Currently no checks against whether already followed
    @IBAction func followButtonPressed(sender: UIButton) {
        if !isFollowing {
            isFollowing = true
            followButton.setTitle("FOLLOWING", forState: .Normal)
            User.currentUser.followingCount++
            API.sharedAPI.updateFollowings(user.id, unfollow: false) { bool in
                print(bool)
            }
        } else {
            isFollowing = false
            followButton.setTitle("FOLLOW", forState: .Normal)
            User.currentUser.followingCount--
            API.sharedAPI.updateFollowings(user.id, unfollow: true) { bool in
                print(bool)
            }
        }
    }
    
    @IBAction func followersButtonPressed(sender: UIButton) {
		displayUsers(.Followers)
    }

    @IBAction func followingButtonPressed(sender: UIButton) {
        displayUsers(.Following)
    }
	
	private func displayUsers(displayType: DisplayType) {
		let followersVC = UsersViewController(nibName: "UsersViewController", bundle: nil)
		followersVC.displayType = displayType
		followersVC.user = user
		followersVC.title = String(displayType)
		navigationController?.pushViewController(followersVC, animated: true)
	}
	
    // <------------------------POST HISTORY------------------------>
    
    // When post history label clicked
    @IBAction func scrollToTop(sender: UIButton) {
        collectionView.setContentOffset(CGPointZero, animated: true)
    }
    
    // Helper Methods
    private func dateForIndexPath(indexPath: NSIndexPath) -> NSDate {
        let date = NSDate().dateByAddingMonths(-indexPath.section).lastDayOfMonth()
        let components: NSDateComponents = date.components()
        components.day = date.numDaysInMonth() - indexPath.item
        return NSDate.dateFromComponents(components)
    }
	
	private func determineAlpha(likes: Int) -> CGFloat {
		let ratio = Float(likes) / avgLikes
		
		if (ratio <= 0.2) {
			return 0.5
		} else if ratio <= 0.4 {
			return 0.60
		} else if ratio <= 0.6 {
			return 0.65
		} else if ratio <= 0.8 {
			return 0.70
		} else if ratio <= 1.0 {
			return 0.75
		} else if ratio <= 1.5 {
			return 0.80
		} else if ratio <= 2.0 {
			return 0.85
		} else if ratio <= 2.5 {
			return 0.90
		} else if ratio <= 3.0 {
			return 0.95
		} else { return 1 }
	}
	
	// MARK: - UICollectionViewDataSource
	
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let date = dateForIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! HipCalendarDayCollectionViewCell
        cell.date = date
		
		if let index = postedDays.indexOf(cell.date.day()) where cell.date.month() == postedDates[index].month() && cell.date.year() == postedDates[index].year() {
			let alpha = determineAlpha(postedLikes[index])
			cell.dayInnerCircleView.backgroundColor = UIColor.iceDarkRed.colorWithAlphaComponent(alpha)
			cell.userInteractionEnabled = true
        }
		
        return cell
    }
	
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let firstDayOfMonth = dateForIndexPath(indexPath).firstDayOfMonth()
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HipCalendarCollectionReusableView
            header.firstDayOfMonth = firstDayOfMonth
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return earliestPostDate?.firstDayOfMonth().numberOfMonths(NSDate()) ?? 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return NSDate().firstDayOfMonth().dateByAddingMonths(-section).numDaysInMonth()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let date = dateForIndexPath(indexPath)
			
        // Push to TableView with posted songs and dates
        let postHistoryVC = PostHistoryTableViewController(nibName: "PostHistoryTableViewController", bundle: nil)
		postHistoryVC.posts = posts
        postHistoryVC.postedDates = postedDates
		postHistoryVC.songLikes = postedLikes
		if let index = postedDays.indexOf(date.day()) {
			postHistoryVC.index = index
		}
        navigationController?.pushViewController(postHistoryVC, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
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

