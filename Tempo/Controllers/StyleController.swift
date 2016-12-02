//
//  StyleController.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/8/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class StyleController {
	class func applyStyles() {
		// UIKit appearances
		UINavigationBar.appearance().barTintColor = .tempoRed
		UINavigationBar.appearance().tintColor = .white
		UINavigationBar.appearance().barStyle = .black
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18.0)!, NSForegroundColorAttributeName: UIColor.white]
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		
		UISearchBar.appearance().backgroundImage = UIImage()
		UISearchBar.appearance().backgroundColor = .tempoRed
		UISearchBar.appearance().barTintColor = .tempoRed
		UISearchBar.appearance().tintColor = .white
		UISearchBar.appearance().isTranslucent = true
		UISearchBar.appearance().placeholder = "Search"
		UISearchBar.appearance().searchBarStyle = .prominent
		
		if #available(iOS 9.0, *) {
			UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .searchBackgroundRed
			UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .searchTextColor
			
			UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 14.0)!], for: UIControlState())
		}
		
		UITableView.appearance().backgroundColor = .backgroundDarkGrey
		UITableView.appearance().separatorColor = .clear
		UITableView.appearance().separatorStyle = .none
		UITableView.appearance().sectionHeaderHeight = 0
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().rowHeight = 96
		
		UITableViewCell.appearance().backgroundColor = .readCellColor
		
		// User defined appearances
		PostButton.appearance().backgroundColor = .tempoRed
		SearchPostView.appearance().backgroundColor = .searchBackgroundRed
	}
}
