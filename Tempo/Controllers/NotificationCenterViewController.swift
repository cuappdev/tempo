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
	var unreadNotificationCount = 0
	let length = 40
	var page = 0
	let postHistoryVC = PostHistoryTableViewController()
	var tableView: UITableView!
	let reuseIdentifier: String = "NotificationCell"
	var firstLoad = true
	
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
		
		initializeTableView()
		
		notifications = [NotificationType : [TempoNotification]]()
		notifications[.Follower] = []
		notifications[.Like] = []
		
		refreshNotifications()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let _ = notConnected(true)
	}
	
	func initializeTableView() {
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabBarHeight - miniPlayerHeight))
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		tableView.rowHeight = notificationCellHeight
		tableView.showsVerticalScrollIndicator = true
		refreshControl = customRefresh.refreshControl
		tableView.insertSubview(refreshControl, belowSubview: tableView.getScrollView()!)
		view.addSubview(tableView)
	}
	
	func refreshNotifications() {
		//finished refreshing gets set to true when the api returns
		var finishedRefreshingNotifs = false
		var finishedRefreshingHistory = false
		
		API.sharedAPI.fetchPosts(User.currentUser.id) { (posts) in
			self.postHistoryVC.posts = posts
			self.postHistoryVC.postedDates = posts.map { $0.date! }
			self.postHistoryVC.filterPostedDatesToSections(self.postHistoryVC.postedDates)
			self.postHistoryVC.songLikes = posts.map{ $0.likes }
			finishedRefreshingHistory = true
			
			if (finishedRefreshingNotifs) {
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.refreshControl.endRefreshing()
				}
			}
		}
		
		API.sharedAPI.fetchNotifications(User.currentUser.id, length: length, page: page) { (notifs) in
			self.notifications[.Follower] = []
			self.notifications[.Like] = []
			self.unreadNotificationCount = 0
			for notif in notifs {
				self.notifications[notif.type]?.append(notif)
				if !notif.seen! { self.unreadNotificationCount += 1 }
			}
			finishedRefreshingNotifs = true
			
			if (finishedRefreshingHistory) {
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.refreshControl.endRefreshing()
				}
			}
		}
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
