//
//  StyleController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/8/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class StyleController {
	class func applyStyles() {
		// UIKit appearances
		UINavigationBar.appearance().barTintColor = UIColor.iceDarkRed
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().barStyle = .Black
		UINavigationBar.appearance().translucent = false
		
		UISearchBar.appearance().backgroundColor = UIColor.iceDarkRed
		UISearchBar.appearance().barTintColor = UIColor.whiteColor()
		UISearchBar.appearance().tintColor = UIColor.whiteColor()
		UISearchBar.appearance().translucent = false
		UISearchBar.appearance().placeholder = "Search"
		UISearchBar.appearance().searchBarStyle = UISearchBarStyle.Minimal
		
		UITableView.appearance().backgroundColor = UIColor.iceLightGray
		UITableView.appearance().separatorColor = UIColor.clearColor()
		UITableView.appearance().separatorStyle = .None
		UITableView.appearance().sectionHeaderHeight = 0
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().rowHeight = 96
		
		UITableViewCell.appearance().backgroundColor = UIColor.iceLightGray
		
		// User defined appearances
		PostButton.appearance().backgroundColor = UIColor.iceDarkRed
		SearchPostView.appearance().backgroundColor = UIColor.iceLightGray
	}
}