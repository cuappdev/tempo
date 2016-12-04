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
    var selectionHandler: ((UIViewController?) -> ())?
    
    var searchNavigationController: UINavigationController!
    var elements: [SideBarElement] = []
    var button: UIButton!
	
	var preselectedIndex: Int? // -1 is profile
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var sideView: UIView!
    
    @IBAction func logOut(_ sender: UIButton) {
		FBSDKAccessToken.setCurrent(nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.toggleRootVC()
		appDelegate.feedVC.refreshNeeded = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.register(UINib(nibName: "SideBarTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        // Formatting
        categoryTableView.separatorStyle = .none
        categoryTableView.isScrollEnabled = false
        categoryTableView.backgroundColor = .readCellColor
		categoryTableView.rowHeight = 65
        profileView.backgroundColor = .readCellColor
        view.backgroundColor = .readCellColor
        divider.backgroundColor = .readCellColor

		sideView.isHidden = true
		sideView.backgroundColor = .tempoRed
		
		profilePicture.frame = CGRect(x: 0, y: 0, width: 85, height: 85)
		profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
		profilePicture.clipsToBounds = true
		
		// Add button to profile view
		button = UIButton(type: .system)
		button.frame = profileView.bounds
		button.addTarget(self, action: #selector(pushToProfile(_:)), for: .touchUpInside)
		view.addSubview(button)
		
		categoryTableView.reloadData()
		
		// Mark first item selected unless there was a preselected item
		if elements.count > 0 {
			if let selectedIndex = preselectedIndex {
				if selectedIndex == -1 {
					profileView.backgroundColor = .unreadCellColor
					sideView.isHidden = false
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
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
		
		// Mark first item selected unless there was a preselected item
		if let selectedIndex = preselectedIndex {
			if selectedIndex == -1 {
				profileView.backgroundColor = .unreadCellColor
				sideView.isHidden = false
				categoryTableView.selectRow(at: nil, animated: false, scrollPosition: .none)
			} else {
				categoryTableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
			}
			preselectedIndex = nil
		}
	}
	
	func pushToProfile(_ sender:UIButton!) {
		profileView.backgroundColor = .unreadCellColor
		sideView.isHidden = false
		let loginVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
		loginVC.user = User.currentUser
		selectionHandler?(loginVC)
		categoryTableView.selectRow(at: nil, animated: false, scrollPosition: .none)
	}
	
	// TableView Methods
	
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
		sideView.isHidden = true
	}
	
}
