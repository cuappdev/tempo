//
//  NotificationCenterViewController.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

let notificationCellHeight: CGFloat = 60

class NotificationCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate {
	
	var notifications: [TempoNotification] = []
	let length = 20
	var page = 0
	var isLoadingMore = false
	var users: [String: User] = [String: User]()
	let postHistoryVC = PostHistoryTableViewController()
	var tableView: UITableView!
	let reuseIdentifier: String = "NotificationCell"
	var firstLoad: Bool = true
	
	override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
		view.backgroundColor = .readCellColor
		firstLoad = true
		
		initializeTableView()
		fetchPostHistory()
		fetchNotifications()
	}
	
	func initializeTableView() {
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight))
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		tableView.rowHeight = 60
		tableView.showsVerticalScrollIndicator = true
		view.addSubview(tableView)
	}
	
	func fetchNotifications() {
		API.sharedAPI.fetchNotifications(User.currentUser.id, length: length, page: page) { (notifs) in
			print(notifs.count)
			var count = 0
			for notif in notifs {
				self.notifications.append(notif)
				API.sharedAPI.fetchUser(notif.userId!, completion: { (user) in
					self.users[notif.id!] = user
					print("Appending")
					count += 1
					if count == notifs.count {
						DispatchQueue.main.async {
							print("Reloading tableview")
							self.tableView.reloadData()
						}
					}
				})
			}
			
			self.isLoadingMore = false
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
	
	// MARK: - Table View Delegate Methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return notifications.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationTableViewCell
		
		let notif = notifications[indexPath.row]
		if let user = users[notif.id!] {
			cell.setupCell(notification: notif, user: user)
			cell.markAsSeen()
			cell.delegate = self
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! NotificationTableViewCell
		
		let navController = navigationController as! PlayerNavigationController
		navController.didTapNotification(forNotification: cell.notification, cell: cell, postHistoryVC: postHistoryVC)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return notificationCellHeight
	}
	
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		let contentOffset = scrollView.contentOffset.y
//		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
//		if !isLoadingMore && (maximumOffset - contentOffset <= CGFloat(0)) {
//			self.isLoadingMore = true
//			let completion: ([TempoNotification]) -> Void = {
//				for notif in $0 {
//					self.notifications.append(notif)
//					API.sharedAPI.fetchUser(notif.userId!) {
//						self.users.append($0)
//					}
//				}
//				DispatchQueue.main.async {
//					self.tableView.reloadData()
//				}
//				self.isLoadingMore = false
//			}
//			page += 1
//			API.sharedAPI.fetchNotifications(User.currentUser.id, length: length, page: page, completion: completion)
//		}
//	}
	
	// MARK: - Delegate
	func didTapUserImageForNotification(_ user: User) {
		let profileVC = ProfileViewController()
		profileVC.title = "Profile"
		profileVC.user = user
		navigationController?.pushViewController(profileVC, animated: true)
	}
	
}