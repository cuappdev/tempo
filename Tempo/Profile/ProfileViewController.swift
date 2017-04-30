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

class ProfileViewController: UIViewController, UIViewControllerTransitioningDelegate, ProfileHeaderViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	let headerViewHeight: CGFloat = 320
	let postHistoryVC = PostHistoryTableViewController()
	
    var user: User!
	
	var scrollView: UIScrollView!
    
    // Post History Calendar
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	var posts: [Post] = []
	var postedDates: [Date] = []
	var postedDays: [Int] = []
	var postedYearMonthDay: [String] = []
	var postedLikes: [Int] = []
	var padding: CGFloat = 5
	var avgLikes: Float = 0
	var justLoaded: Bool = true

	var profileHeaderView: ProfileHeaderView!
	var calendarCollectionView: UICollectionView!
	var calendarCollectionViewDivider: UIView!
	var activityIndicatorView: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if user == nil || user == User.currentUser {
			user = User.currentUser
			
			let settingsItem = UIBarButtonItem(image: UIImage(named: "SettingsIcon"), style: .plain, target: self, action: #selector(navigateToSettings))
			settingsItem.imageInsets = UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 10.0)
			navigationItem.rightBarButtonItem = settingsItem
		}
		
		view.backgroundColor = .profileBackgroundBlack
		
		edgesForExtendedLayout = []
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
		
		let statusbarHeight = UIApplication.shared.statusBarFrame.height
		let navbarHeight = navigationController?.navigationBar.frame.height ?? 44
		let scrollViewHeight = view.frame.height - statusbarHeight - navbarHeight - tabBarHeight - miniPlayerHeight
		
		scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: scrollViewHeight))
		scrollView.bounces = false
		scrollView.showsVerticalScrollIndicator = false
		view.addSubview(scrollView)
		
		// Set up profile header view
		profileHeaderView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerViewHeight))
		profileHeaderView.delegate = self

		// Set up profile calendar
		let layout = HipStickyHeaderFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 0, left: padding*6, bottom: padding*2, right: 0)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0

		calendarCollectionView = UICollectionView(frame: CGRect(x: 0, y: profileHeaderView.frame.bottom.y, width: view.frame.width, height: view.frame.height), collectionViewLayout: layout)
		calendarCollectionView.delegate = self
		calendarCollectionView.dataSource = self
		calendarCollectionView.backgroundColor = .profileBackgroundBlack
		calendarCollectionView.scrollsToTop = false

		calendarCollectionView.register(HipCalendarCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
		calendarCollectionView.register(HipCalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: "DayCell")
		
		calendarCollectionViewDivider = UIView(frame: CGRect(x: view.frame.width/11, y: 0, width: 1, height: view.frame.height))
		calendarCollectionViewDivider.backgroundColor = .tempoRed
		
		scrollView.addSubview(calendarCollectionView)
		scrollView.addSubview(calendarCollectionViewDivider)
		scrollView.addSubview(profileHeaderView)
		scrollView.contentSize = CGSize(width: view.frame.width, height: profileHeaderView.frame.height + calendarCollectionView.frame.height)
		
		setupUserUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		justLoaded ? justLoaded = false : setupUserUI()
		
		profileHeaderView.nameLabel.isHidden = notConnected(true)
		profileHeaderView.usernameButton.isHidden = notConnected(false)
		
		calendarCollectionView.isUserInteractionEnabled = true
		profileHeaderView.followingButton.isEnabled = true
		profileHeaderView.followersButton.isEnabled = true
		navigationItem.rightBarButtonItem?.isEnabled = true
	}
	
	// MARK: - UI Setup and Update Methods

	func setupUserUI() {
		if let _ = user {
			API.sharedAPI.fetchPosts(user.id) { post in
				self.posts = post
				self.postedDates = post.map { $0.date! }
				self.postedDays = self.postedDates.map { $0.day() }
				self.postedYearMonthDay = self.postedDates.map { $0.yearMonthDay() }
				self.postedLikes = post.map{ $0.likes }

				self.calendarCollectionView.reloadData()
				DispatchQueue.main.async {
					self.calendarCollectionView.frame = CGRect(x: self.calendarCollectionView.frame.origin.x,
															   y: self.calendarCollectionView.frame.origin.y,
															   width: self.calendarCollectionView.frame.width,
															   height: self.calendarCollectionView.contentSize.height)
					self.scrollView.contentSize = CGSize(width: self.view.frame.width,
														 height: self.calendarCollectionView.frame.height + self.profileHeaderView.frame.height)
					self.calendarCollectionViewDivider.frame = CGRect(x: self.view.frame.width/11,
																	  y: self.calendarCollectionView.frame.origin.y,
																	  width: 1,
																	  height: self.scrollView.contentSize.height * 2)
				}
				
				for likes in self.postedLikes {
					self.avgLikes += Float(likes)
				}
				self.avgLikes /= Float(self.postedLikes.count)
				
				self.activityIndicatorView.stopAnimating()
				self.activityIndicatorView.removeFromSuperview()
			}
			
			profileHeaderView.nameLabel.text = "\(user.firstName) \(user.shortenLastName())"
			profileHeaderView.usernameButton.setTitle("@\(user.username)", for: .normal)
			
			profileHeaderView.profileImageView.hnk_setImageFromURL(user.imageURL)
			profileHeaderView.profileBackgroundImageView.hnk_setImageFromURL(user.imageURL)

			if User.currentUser.username == user.username {
				title = "My Profile"
				profileHeaderView.profileButton.setTitle("EDIT", for: .normal)
				profileHeaderView.profileButton.addTarget(self, action: #selector(userHandleButtonClicked(sender:)), for: .touchUpInside)
			} else {
				title = "Profile"
				profileHeaderView.profileButton.addTarget(self, action: #selector(profileButtonPressed(sender:)), for: .touchUpInside)
			}
			
			API.sharedAPI.fetchUser(user.id) {
				self.user = $0
				self.updateProfileInfoUI()
			}
		}
	}
	
	func updateProfileInfoUI() {
		if User.currentUser.username != user.username {
			profileHeaderView.profileButton.setTitle(user.isFollowing ? "FOLLOWING" : "FOLLOW", for: UIControlState())
			profileHeaderView.profileButton.backgroundColor = (user.isFollowing) ? .clear : .tempoRed
		}
		
		profileHeaderView.followingLabel.text = "\(user.followingCount)"
		profileHeaderView.followersLabel.text = "\(user.followersCount)"
		profileHeaderView.hipsterScoreLabel.text = "\(user.hipsterScore)"
	}
	
	fileprivate func displayUsers(_ displayType: DisplayType) {
		let followersVC = UsersViewController()
		followersVC.displayType = displayType
		followersVC.user = user
		followersVC.title = String(describing: displayType)
		profileHeaderView.followersButton.isEnabled = false
		profileHeaderView.followingButton.isEnabled = false
		navigationController?.pushViewController(followersVC, animated: true)
	}
	
	// MARK: - Profile Header View Delegate Methods
	
	func hipsterScoreButtonPressed() {
		print("Hipster score button pressed")
	}
	
	func followersButtonPressed() {
		displayUsers(.Followers)
	}
	
	func followingButtonPressed() {
		displayUsers(.Following)
	}
	
    // <------------------------FOLLOW BUTTONS------------------------>
	
	func profileButtonPressed(sender: UIButton) {
		user.isFollowing = !user.isFollowing
		User.currentUser.followingCount += user.isFollowing ? 1 : -1
		user.followersCount += user.isFollowing ? 1 : -1
		API.sharedAPI.updateFollowings(user.id, unfollow: !user.isFollowing)
		updateProfileInfoUI()
	}
	
	func userHandleButtonClicked(sender: UIButton) {
		let editAlert = UIAlertController(title: "Edit Username", message: "This is how you appear to other users.", preferredStyle: .alert)
		editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		editAlert.addTextField { textField in
			textField.placeholder = "New username"
			textField.textAlignment = .center
			textField.keyboardAppearance = .dark
		}
		editAlert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
			let newUsername = editAlert.textFields!.first!.text!.lowercased()
			let charSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted
			let invalidChars = newUsername.rangeOfCharacter(from: charSet)
			
			if newUsername == "" {
				self.showErrorAlert("Oh no!", message: "Username must have at least one character.", actionTitle: "Try again")
			} else if invalidChars != nil {
				self.showErrorAlert("Invalid characters", message: "Only underscores and alphanumeric characters are allowed.", actionTitle: "Try again")
			} else if newUsername.characters.count > 18 {
				self.showErrorAlert("Invalid length", message: "Username is too long.", actionTitle: "Try again")
			} else if CharacterSet.decimalDigits.contains(newUsername.unicodeScalars.first!) || newUsername.characters.first == "_" {
				self.showErrorAlert("Invalid start", message: "Usernames can only start with letters.", actionTitle: "Try again")
			} else {
				let oldUsername = User.currentUser.username
				
				if newUsername.lowercased() != oldUsername.lowercased() {
					API.sharedAPI.updateCurrentUser(newUsername) { success in
						if success {
							self.profileHeaderView.usernameButton.setTitle("@\(User.currentUser.username)", for: .normal)
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
	
	//TO DO: PREVENT MULTIPLE CLICKS !!!
	func navigateToSettings() {
		print("go to settings!!")
		navigationItem.rightBarButtonItem?.isEnabled = false
		navigationController?.pushViewController(SettingsScrollViewController.sharedInstance, animated: true)
	}

	/* <------------------------POST HISTORY------------------------> */
	
	// MARK: - Post History Helper Methods
	
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
	
	// MARK: - Calendar Collection View Delegate Methods
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width - padding * 2, height: 30)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cols: CGFloat = 6
		let dayWidth = collectionView.frame.width / cols
		let dayHeight = dayWidth
		
		return CGSize(width: dayWidth, height: dayHeight)
	}
	
	// MARK: - UICollectionViewDelegate Methods
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let date = dateForIndexPath(indexPath)
		
		// Push to TableView with posted songs and dates
		postHistoryVC.posts = posts
		postHistoryVC.postedDates = postedDates
		postHistoryVC.filterPostedDatesToSections(postedDates)
		postHistoryVC.songLikes = postedLikes
		
		if let sectionIndex = postHistoryVC.postedDatesSections.index(of: date.yearMonthDay()) {
			postHistoryVC.sectionIndex = sectionIndex
			postHistoryVC.rowIndex = 0
		}
		
		calendarCollectionView.isUserInteractionEnabled = false
		navigationController?.pushViewController(postHistoryVC, animated: true)
	}
	
	// MARK: - UICollectionViewDataSource Methods
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let date = dateForIndexPath(indexPath)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! HipCalendarDayCollectionViewCell
		cell.date = date
		cell.isUserInteractionEnabled = true
		
		if let index = postedYearMonthDay.index(of: date.yearMonthDay()) {
			let alpha = determineAlpha(postedLikes[index])
			cell.dayInnerCircleView.backgroundColor = UIColor.tempoRed.withAlphaComponent(alpha)
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

		var dateComponents = DateComponents()
		dateComponents.day = 1
		dateComponents.month = 1
		dateComponents.year = 2017
		
		return calendar.date(from: dateComponents)?.firstDayOfMonth().numberOfMonths(Date()) ?? 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Date().firstDayOfMonth().dateByAddingMonths(-section).numDaysInMonth()
	}
}
