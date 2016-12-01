//
//  ProfileViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    var user: User = User.currentUser
    
    // Post History Calendar
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	var posts: [Post] = []
	var postedDates: [Date] = []
	var postedDays: [Int] = []
	var postedYearMonthDay: [String] = []
	var postedLikes: [Int] = []
	var earliestPostDate: Date?
	var padding: CGFloat = 5
	var avgLikes: Float = 0
	
	// Outlets
	@IBOutlet weak var profilePictureView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var hipsterCredButton: UIButton!
	@IBOutlet weak var followersButton: UIButton!
	@IBOutlet weak var followingButton: UIButton!
	@IBOutlet weak var separator: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hipsterCredLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
	
	var activityIndicatorView: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		followButton.layer.borderWidth = 1.5
		followButton.layer.borderColor = UIColor.tempoLightRed.cgColor
		followButton.backgroundColor = UIColor.clear
		
		activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
		
		// Post History Calendar
		separator.backgroundColor = UIColor.tempoLightRed
		
		let layout = collectionView.collectionViewLayout as! HipStickyHeaderFlowLayout
		layout.sectionInset = UIEdgeInsets(top: 0, left: padding*6, bottom: padding*2, right: 0)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		
		collectionView.register(HipCalendarCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
		collectionView.register(HipCalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "DayCell")
		collectionView.backgroundColor = UIColor.clear
		collectionView.scrollsToTop = false
		collectionView.alpha = 0.0
		
		// Check for 3D Touch availability
		if #available(iOS 9.0, *) {
			if traitCollection.forceTouchCapability == .available {
				registerForPreviewing(with: self, sourceView: view)
			}
		}
		
		setupUserUI()
		updateFollowingUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		nameLabel.isHidden = notConnected(true)
		usernameLabel.isHidden = notConnected(false)
		followButton.isHidden = notConnected(false)

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if collectionView.alpha == 0.0 {
			activityIndicatorView.center = CGPoint(x: view.frame.width / 2.0, y: collectionView.center.y)
			activityIndicatorView.startAnimating()
			view.addSubview(activityIndicatorView)
		}
	}

	func setupUserUI() {
		
		API.sharedAPI.fetchPosts(user.id) { post in
			self.posts = post
			self.postedDates = post.map { $0.date! }
			self.postedDays = self.postedDates.map { $0.day() }
			self.postedYearMonthDay = self.postedDates.map { $0.yearMonthDay() }
			self.postedLikes = post.map{ $0.likes }
			self.collectionView.alpha = 1.0
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
			
			self.activityIndicatorView.stopAnimating()
			self.activityIndicatorView.removeFromSuperview()
		}
		
		// Profile Info
		if user == User.currentUser {
			addHamburgerMenu()
		}
		
		nameLabel.text = "\(user.firstName) \(user.shortenLastName())"
		usernameLabel.text = "@" + user.username
		hipsterCredLabel.text = "\(user.hipsterScore)"
		
		profilePictureView.hnk_setImageFromURL(user.imageURL)

        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.height/2
        profilePictureView.clipsToBounds = true

		if User.currentUser.username == user.username {
			title = "My Profile"
			followButton.setTitle("EDIT", for: UIControlState())
			followButton.addTarget(self, action: #selector(ProfileViewController.userHandleButtonClicked(_:)), for: .touchUpInside)
		} else {
			title = "Profile"
			followButton.isHidden = true
			followButton.addTarget(self, action: #selector(followButtonPressed(_:)), for: .touchUpInside)
			}
		
		API.sharedAPI.fetchUser(user.id) {
			self.user = $0
			self.updateFollowingUI()
			self.followButton.isHidden = false
			UIView.animate(withDuration: 0.25, animations: {
				self.followButton.alpha = 1
			}) 
		}
	}
	
    // <------------------------FOLLOW BUTTONS------------------------>
	
	@IBAction func followButtonPressed(_ sender: UIButton) {
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		updateFollowingUI()
	}
	
	func updateFollowingUI() {
		if User.currentUser.username != user.username {
			followButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
			followButton.backgroundColor = (user.isFollowing) ? UIColor.tempoLightGray : UIColor.tempoLightRed
		}

		followingLabel.text = "\(user.followingCount)"
		followersLabel.text = "\(user.followersCount)"
	}
	
    @IBAction func hipsterCredButtonPressed(_ sender: UIButton) {
		// We should display to the user how hipster score is calculated for gamification.
    }
	
	@IBAction func followersButtonPressed(_ sender: UIButton) {
		displayUsers(.Followers)
	}
	
	@IBAction func followingButtonPressed(_ sender: UIButton) {
		displayUsers(.Following)
	}
	
	fileprivate func displayUsers(_ displayType: DisplayType) {
		let followersVC = UsersViewController()
		followersVC.displayType = displayType
		followersVC.user = user
		followersVC.title = String(describing: displayType)
		navigationController?.pushViewController(followersVC, animated: true)
	}
	
	@IBAction func userHandleButtonClicked(_ sender: UIButton) {
		let editAlert = UIAlertController(title: "Edit Username", message: "This is how you appear to other users.", preferredStyle: .alert)
		editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		editAlert.addTextField { textField in
			textField.placeholder = "New username"
			textField.textAlignment = .center
		}
		editAlert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
			let newUsername = editAlert.textFields!.first!.text!.lowercased()
			let charSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted
			let invalidChars = newUsername.rangeOfCharacter(from: charSet)
			
			if newUsername == "" {
				self.showErrorAlert("Oh no!", message: "Username must have at least one character.", actionTitle: "Try again")
			} else if invalidChars != nil {
				self.showErrorAlert("Invalid characters", message: "Only underscores and alphanumeric characters are allowed.", actionTitle: "Try again")
			} else if newUsername.characters.count > 18{
				self.showErrorAlert("Invalid length", message: "Username is too long.", actionTitle: "Try again")
			} else {
				let oldUsername = User.currentUser.username
				
				if newUsername.lowercased() != oldUsername.lowercased() {
					API.sharedAPI.updateCurrentUser(newUsername) { success in
						if success {
							self.usernameLabel.text = "@\(User.currentUser.username)"
						} else {
							self.showErrorAlert("Sorry!", message: "Username is taken.", actionTitle: "Try again")
						}
						
					}
				}
			}
			})
		present(editAlert, animated: true, completion: nil)
	}
	
	func showErrorAlert(_ title: String, message: String, actionTitle: String) {
		let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		errorAlert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
		present(errorAlert, animated: true, completion: nil)
	}
	
	// <------------------------POST HISTORY------------------------>
	
	// When post history label clicked
	@IBAction func scrollToTop(_ sender: UIButton) {
		collectionView.setContentOffset(CGPoint.zero, animated: true)
	}
	
	// Helper Methods
	fileprivate func dateForIndexPath(_ indexPath: IndexPath) -> Date {
		let date = Date().dateByAddingMonths(-indexPath.section).lastDayOfMonth()
		var components: DateComponents = date.components()
		components.day = date.numDaysInMonth() - indexPath.item
		return Date.dateFromComponents(components)
	}
	
	fileprivate func determineAlpha(_ likes: Int) -> CGFloat {
		let ratio = Float(likes) / avgLikes
		return -0.0311 * CGFloat(pow(ratio, 2)) + 0.2461 * CGFloat(ratio) + 0.4997
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let date = dateForIndexPath(indexPath)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! HipCalendarDayCollectionViewCell
		cell.date = date
		cell.isUserInteractionEnabled = true
		if let index = postedYearMonthDay.index(of: date.yearMonthDay()) {
			let alpha = determineAlpha(postedLikes[index])
			cell.dayInnerCircleView.backgroundColor = UIColor.tempoLightRed.withAlphaComponent(alpha)
			cell.isUserInteractionEnabled = true
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionElementKindSectionHeader {
			let firstDayOfMonth = dateForIndexPath(indexPath).firstDayOfMonth()
			let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HipCalendarCollectionReusableView
			header.firstDayOfMonth = firstDayOfMonth
			
			return header
		}
		
		return UICollectionReusableView()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return earliestPostDate?.firstDayOfMonth().numberOfMonths(Date()) ?? 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Date().firstDayOfMonth().dateByAddingMonths(-section).numDaysInMonth()
	}
	
	// MARK: - UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let date = dateForIndexPath(indexPath)
		
		// Push to TableView with posted songs and dates
		let postHistoryVC = PostHistoryTableViewController()
		postHistoryVC.posts = posts
		postHistoryVC.postedDates = postedDates
		postHistoryVC.filterPostedDatesToSections(postedDates)
		postHistoryVC.songLikes = postedLikes
		
		if let sectionIndex = postHistoryVC.postedDatesSections.index(of: date.yearMonthDay()) {
			postHistoryVC.sectionIndex = sectionIndex
		}
		
		navigationController?.pushViewController(postHistoryVC, animated: true)
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width - padding * 2, height: 30)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cols: CGFloat = 6
		let dayWidth = collectionView.frame.width / cols
		let dayHeight = dayWidth
		return CGSize(width: dayWidth, height: dayHeight)
	}
	
}

@available(iOS 9.0, *)
extension ProfileViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		
		if followersButton.frame.contains(location) {
			let followersVC = UsersViewController()
			followersVC.displayType = .Followers
			followersVC.user = user
			followersVC.title = String(describing: followersVC.displayType)
			
			previewingContext.sourceRect = followersButton.frame
			
			return followersVC
		}
		
		if followingButton.frame.contains(location) {
			let followersVC = UsersViewController()
			followersVC.displayType = .Following
			followersVC.user = user
			followersVC.title = String(describing: followersVC.displayType)
			
			previewingContext.sourceRect = followingButton.frame
			
			return followersVC
		}
		
		let collectionViewPoint = view.convert(location, to: collectionView)
		
		guard let indexPath = collectionView.indexPathForItem(at: collectionViewPoint),
			let cell = collectionView.cellForItem(at: indexPath) as? HipCalendarDayCollectionViewCell else {
				return nil
		}
		
		if postedYearMonthDay.index(of: cell.date.yearMonthDay()) != nil {
			
			let date = dateForIndexPath(indexPath)
			
			let peekViewController = PostHistoryTableViewController()
			peekViewController.posts = posts
			peekViewController.postedDates = postedDates
			peekViewController.filterPostedDatesToSections(postedDates)
			peekViewController.songLikes = postedLikes
			
			if let sectionIndex = peekViewController.postedDatesSections.index(of: date.yearMonthDay()) {
				peekViewController.sectionIndex = sectionIndex
			}
			
			peekViewController.preferredContentSize = CGSize.zero
			previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
			
			return peekViewController
		}
		
		return nil
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		show(viewControllerToCommit, sender: self)
	}
}
