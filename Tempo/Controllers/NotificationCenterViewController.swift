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
	
	var notifications: [TempoNotification] = []
	let length = 20
	var page = 0
	var isLoadingMore = false
	let postHistoryVC = PostHistoryTableViewController()
	var tableView: UITableView!
	let reuseIdentifier: String = "NotificationCell"
	
	override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
		view.backgroundColor = .readCellColor
		
		initializeTableView()
		fetchPostHistory()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchNotifications()
	}
	
	func initializeTableView() {
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		tableView.rowHeight = notificationCellHeight
		tableView.showsVerticalScrollIndicator = true
		view.addSubview(tableView)
	}
	
	func fetchNotifications() {
		API.sharedAPI.fetchNotifications(User.currentUser.id, length: length, page: page) { (notifs) in
			for notif in notifs {
				self.notifications.append(notif)
			}
			self.isLoadingMore = false
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	func fetchPostHistory() {
		API.sharedAPI.fetchPosts(User.currentUser.id) { (posts) in
			DispatchQueue.main.async {
				self.postHistoryVC.posts = posts
				self.postHistoryVC.postedDates = posts.map { $0.date! }
				self.postHistoryVC.filterPostedDatesToSections(self.postHistoryVC.postedDates)
				self.postHistoryVC.songLikes = posts.map{ $0.likes }
			}
		}
	}
	
	// MARK: - Table View Delegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notifications.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationTableViewCell
		
		let notif = notifications[indexPath.row]
		cell.setupCell(notification: notif)
//		cell.markAsSeen()
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
		let contentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
		if !isLoadingMore && (maximumOffset - contentOffset <= CGFloat(0) && notifications.count < 60) {
			self.isLoadingMore = true
			page += 1
			fetchNotifications()
		}
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
			navigationController?.pushViewController(vc, animated: true)
		} else if notif.type == .Follower, let user = notif.user {
			didTapUserImageForNotification(user)
		}
		
		if let cell = cell {
			cell.markAsSeen()
		}
	}
	
}