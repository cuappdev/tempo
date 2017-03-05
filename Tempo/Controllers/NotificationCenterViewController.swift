//
//  NotificationCenterViewController.swift
//  Tempo
//
//  Created by Logan Allen on 2/21/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

class NotificationCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var notifications: [TempoNotification] = []
	var tableView: UITableView!
	let reuseIdentifier: String = "NotificationCell"
	
	override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
		view.backgroundColor = .readCellColor
		
		initializeTableView()
		
		refreshNotifications()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshNotifications()
	}
	
	func initializeTableView() {
		tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - playerCellHeight))
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .readCellColor
		tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		tableView.rowHeight = 50
		tableView.showsVerticalScrollIndicator = true
		view.addSubview(tableView)
	}
	
	func refreshNotifications() {
		print("Fetching notification data")
		API.sharedAPI.fetchNotifications(User.currentUser.id) { [weak self] (notifications: [TempoNotification]) in
			DispatchQueue.main.async {
				self?.notifications = notifications
				self?.tableView.reloadData()
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
		cell.setupCell(notification: notif)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! NotificationTableViewCell
		
		let navController = navigationController as! PlayerNavigationController
		navController.didTapNotification(forNotification: cell.notification)
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}


}
