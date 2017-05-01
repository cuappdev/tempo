//
//  NotificationCenterViewController.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

let notificationCellHeight: CGFloat = 60

class NotificationCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate, NotificationDelegate {
	
	var notifications: [NotificationType : [TempoNotification]]!
	let length = 40
	var page = 0
	let postHistoryVC = PostHistoryTableViewController()
	var tableView: UITableView!
	let reuseIdentifier: String = "NotificationCell"
	var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
	
	var refreshControl: UIRefreshControl!
	lazy var customRefresh: ADRefreshControl = {
		self.refreshControl = UIRefreshControl()
		let customRefresh = ADRefreshControl(refreshControl: self.refreshControl!)
		self.refreshControl?.addTarget(self, action: #selector(refreshNotifications), for: .valueChanged)
		return customRefresh
	}()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
		view.backgroundColor = .readCellColor
		
		
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabBarHeight - miniPlayerHeight - notificationCellHeight))
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		tableView.alpha = 0.0
		tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		tableView.rowHeight = notificationCellHeight
		tableView.showsVerticalScrollIndicator = true
		refreshControl = customRefresh.refreshControl
		tableView.insertSubview(refreshControl, belowSubview: tableView.getScrollView()!)
		view.addSubview(tableView)
		
		notifications = [NotificationType : [TempoNotification]]()
		notifications[.Follower] = []
		notifications[.Like] = []
		
		activityIndicatorView.center = tableView.center
		
		refreshNotifications()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let _ = notConnected(true)
	}

	func refreshNotifications() {
		// Finished refreshing gets set to true when each api call returns
		var finishedRefreshingNotifs = false
		var finishedRefreshingHistory = false
		
		if tableView.alpha == 0.0 {
			activityIndicatorView.startAnimating()
			view.addSubview(activityIndicatorView)
		}
		
		// PROBLEM: On first load from push notification these api calls dont work...
		
		API.sharedAPI.fetchPosts(User.currentUser.id) { (posts) in
			finishedRefreshingHistory = true
			
			self.postHistoryVC.posts = posts
			self.postHistoryVC.postedDates = posts.map { $0.date! }
			self.postHistoryVC.filterPostedDatesToSections(self.postHistoryVC.postedDates)
			self.postHistoryVC.songLikes = posts.map{ $0.likes }
			
			if (finishedRefreshingNotifs) {
				DispatchQueue.main.async {
					self.finishRefreshing()
				}
			}
		}
		
		API.sharedAPI.fetchNotifications(User.currentUser.id, length: length, page: page) { (notifs) in
			self.notifications[.Follower] = []
			self.notifications[.Like] = []
			var unreadNotifs = 0
			for notif in notifs {
				self.notifications[notif.type]?.append(notif)
				if !notif.seen! { unreadNotifs += 1 }
			}
			TabBarController.sharedInstance.unreadNotificationCount = unreadNotifs
			finishedRefreshingNotifs = true
			
			if (finishedRefreshingHistory) {
				DispatchQueue.main.async {
					self.finishRefreshing()
				}
			}
		}
		
		// Finish loading and stop animating after timeout
		let popTime = DispatchTime.now() + Double(Int64(8.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: popTime) {
			if !(finishedRefreshingNotifs && finishedRefreshingHistory) {
				self.finishRefreshing()
			}
		}
	}
	
	func finishRefreshing() {
		activityIndicatorView.stopAnimating()
		activityIndicatorView.removeFromSuperview()
		tableView.reloadData()
		refreshControl.endRefreshing()
		tableView.alpha = 1.0
	}
	
	// MARK: - Table View Delegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36))
		headerView.backgroundColor = .readCellColor
		
		let title = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width - 10, height: 36))
		title.font = UIFont(name: "AvenirNext-Medium", size: 15)
		title.textColor = .white
		title.textAlignment = .left
		title.text = (section == 0) ? "Follow Requests" : "Likes"
		headerView.addSubview(title)
		
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 36
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return (section == 0) ? "Follow Requests" : "Likes"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let key: NotificationType = (section == 0) ? .Follower : .Like
		return notifications[key]!.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationTableViewCell
		
		let key: NotificationType = (indexPath.section == 0) ? .Follower : .Like
		let notif = notifications[key]![indexPath.row]
		cell.setupCell(notification: notif)
		cell.delegate = self
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! NotificationTableViewCell
		
		didTapNotification(forNotification: cell.notification, cell: cell, postHistoryVC: postHistoryVC)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return notificationCellHeight
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		customRefresh.scrollViewDidScroll(scrollView)
	}
	
	// MARK: - Notification Cell Delegate
	func didTapUserImageForNotification(_ user: User) {
		let profileVC = ProfileViewController()
		profileVC.title = "Profile"
		profileVC.user = user
		navigationController?.pushViewController(profileVC, animated: true)
	}
	
	// MARK: - Notification Delegate
	func didTapNotification(forNotification notif: TempoNotification, cell: NotificationTableViewCell?, postHistoryVC: PostHistoryTableViewController?) {
		if let postID = notif.postId, notif.type == .Like, let vc = postHistoryVC {
			var row: Int = 0
			for p in vc.posts {
				if p.postID == postID { break }
				row += 1
			}
			vc.sectionIndex = vc.relativeIndexPath(row: row).section
			vc.rowIndex = vc.relativeIndexPath(row: row).row
			navigationController?.pushViewController(vc, animated: true)
		} else if notif.type == .Follower, let user = notif.user {
			didTapUserImageForNotification(user)
		}
		
		if let cell = cell {
			cell.markAsSeen()
		}
	}
	
}
