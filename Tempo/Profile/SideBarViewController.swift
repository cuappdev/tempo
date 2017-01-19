//
//  SideBarViewController.swift
//  Tempo
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKShareKit

struct SideBarElement {
	var title: String
	var viewController: UIViewController
	var image: UIImage?
	
	init(title: String, viewController: UIViewController, image: UIImage?) {
		self.title = title
		self.viewController = viewController
		self.image = image
	}
}

class SideBarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	let padding: CGFloat = 22
	
    var selectionHandler: ((UIViewController?) -> ())?
    var searchNavigationController: UINavigationController!
    var elements: [SideBarElement] = []
    var button: UIButton!
	
	var preselectedIndex: Int? // -1 is profile
	
	var profileView: UIView!
	var highlightView: UIView!
	var initialsView: UIView!
	var initialsLabel: UILabel!
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
	var divider: UIView!
    var categoryTableView: UITableView!
	var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .readCellColor
		
		setUpViews()

		// Add button to profile view
		button = UIButton(type: .system)
		button.frame = profileView.bounds
		button.addTarget(self, action: #selector(pushToProfile(_:)), for: .touchUpInside)
		view.addSubview(button)
		
		categoryTableView.register(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
		categoryTableView.reloadData()
		
		// Mark first item selected unless there was a preselected item
		if elements.count > 0 {
			if let selectedIndex = preselectedIndex {
				if selectedIndex == -1 {
					profileView.backgroundColor = .unreadCellColor
					highlightView.isHidden = false
					categoryTableView.selectRow(at: nil, animated: false, scrollPosition: .none)
				} else {
					categoryTableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
				}
				preselectedIndex = nil
			} else {
				categoryTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		nameLabel.text = "\(User.currentUser.firstName) \(User.currentUser.shortenLastName())"
		usernameLabel.text = "@\(User.currentUser.username)"
		profileImageView.hnk_setImageFromURL(User.currentUser.imageURL)
		
		// Mark first item selected unless there was a preselected item
		if let selectedIndex = preselectedIndex {
			if selectedIndex == -1 {
				profileView.backgroundColor = .unreadCellColor
				highlightView.isHidden = false
				categoryTableView.selectRow(at: nil, animated: false, scrollPosition: .none)
			} else {
				categoryTableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
			}
			preselectedIndex = nil
		}
	}
	
	func setUpViews() {
		// Profile View
		let profileImageLength: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 86 : 102
		let sidebarWidth: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 260 : 300
		let profileImageTopPadding: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 47 : 65
		let nameLabelTopPadding: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 12 : 14
		let tableViewTopPadding: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 25 : 30
		let nameLabelHeight: CGFloat = 25
		let usernameLabelHeight: CGFloat = 22
		
		let profileViewHeight: CGFloat = profileImageTopPadding + profileImageLength + nameLabelTopPadding + nameLabelHeight + usernameLabelHeight + tableViewTopPadding
		
		profileView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: profileViewHeight))
		profileView.backgroundColor = .readCellColor
		
		highlightView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: profileViewHeight))
		highlightView.isHidden = true
		highlightView.backgroundColor = .tempoRed
		
		initialsView = UIImageView(frame: CGRect(x: 0, y: profileImageTopPadding, width: profileImageLength, height: profileImageLength))
		initialsView.center.x = sidebarWidth / 2.0
		initialsView.layer.cornerRadius = initialsView.frame.size.height/2
		initialsView.clipsToBounds = true
		initialsView.backgroundColor = .placeholderGrey
		
		initialsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: initialsView.frame.width, height: 25))
		initialsLabel.text = setUserInitials(firstName: User.currentUser.firstName, lastName: User.currentUser.lastName)
		initialsLabel.font = UIFont(name: "AvenirNext-Medium", size: 30.0)
		initialsLabel.textColor = .placeholderTextGrey
		initialsLabel.textAlignment = .center
		initialsLabel.center = CGPoint(x: initialsView.center.x, y: initialsView.center.y + 2)

		profileImageView = UIImageView(frame: initialsView.frame)
		profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
		profileImageView.clipsToBounds = true
		profileImageView.contentMode = .scaleAspectFill
		
		nameLabel = UILabel(frame: CGRect(x: 0, y: profileImageView.frame.maxY + nameLabelTopPadding, width: 200, height: nameLabelHeight))
		nameLabel.font = UIFont(name: "AvenirNext-Demibold", size: 18.0)
		nameLabel.textColor = .redTintedWhite
		nameLabel.textAlignment = .center
		nameLabel.center.x = profileImageView.center.x
		
		usernameLabel = UILabel(frame: CGRect(x: 0, y: nameLabel.frame.maxY, width: 200, height: usernameLabelHeight))
		usernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		usernameLabel.textColor = .paleRed
		usernameLabel.textAlignment = .center
		usernameLabel.center.x = nameLabel.center.x
		
		divider = UIView(frame: CGRect(x: 0, y: profileViewHeight - 1, width: view.bounds.width, height: 1))
		divider.backgroundColor = UIColor.unreadCellColor.withAlphaComponent(0.46)
		
		// Category Table View
		let categoryCellHeight: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 55 : 65
		
		categoryTableView = UITableView(frame: CGRect(x: 0, y: profileView.frame.maxY, width: view.bounds.width, height: categoryCellHeight*5))
		categoryTableView.delegate = self
		categoryTableView.dataSource = self
		categoryTableView.rowHeight = categoryCellHeight
		categoryTableView.backgroundColor = .readCellColor
		categoryTableView.separatorStyle = .none
		categoryTableView.isScrollEnabled = false
		
		// Logout Button
		let logoutButtonHeight: CGFloat = 40
		let logoutButtonYOffset: CGFloat = DeviceType.IS_IPHONE_5_OR_LESS ? 18 : 22
		
		logoutButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - logoutButtonYOffset - logoutButtonHeight, width: 80, height: logoutButtonHeight))
		logoutButton.center.x = profileImageView.center.x
		logoutButton.setTitle("Logout", for: .normal)
		logoutButton.setTitleColor(.tempoMidGrey, for: .normal)
		logoutButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		logoutButton.addTarget(self, action: #selector(logOut(_:)), for: .touchUpInside)
		
		profileView.addSubview(highlightView)
		profileView.addSubview(initialsView)
		profileView.addSubview(initialsLabel)
		profileView.addSubview(profileImageView)
		profileView.addSubview(nameLabel)
		profileView.addSubview(usernameLabel)
		profileView.addSubview(divider)
		
		view.addSubview(profileView)
		view.addSubview(categoryTableView)
		view.addSubview(logoutButton)
	}
	
	// MARK: - Button Action Methods
	
	func pushToProfile(_ sender:UIButton!) {
		profileView.backgroundColor = .unreadCellColor
		highlightView.isHidden = false
		let loginVC = ProfileViewController()
		loginVC.user = User.currentUser
		selectionHandler?(loginVC)
		categoryTableView.selectRow(at: nil, animated: false, scrollPosition: .none)
	}
	
	func logOut(_ sender: UIButton) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.navigationController.resetPlayerCells()
		FBSDKAccessToken.setCurrent(nil)
		appDelegate.toggleRootVC()
		appDelegate.feedVC.refreshNeeded = true
	}
	
	// MARK: - TableView Methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return elements.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SideBarTableViewCell
		let element = elements[indexPath.row]
		
		cell.categorySymbol.image = element.image
		cell.categoryLabel.text = element.title
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let element = elements[indexPath.row]
		selectionHandler?(element.viewController)
		profileView.backgroundColor = .clear
		highlightView.isHidden = true
	}
	
}
