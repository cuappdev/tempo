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
		UINavigationBar.appearance().barTintColor = UIColor.tempoLightRed
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().barStyle = .Black
		UINavigationBar.appearance().translucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 17.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
		
		UISearchBar.appearance().backgroundImage = UIImage()
		UISearchBar.appearance().backgroundColor = UIColor.tempoLightRed
		UISearchBar.appearance().barTintColor = UIColor.tempoLightRed
		UISearchBar.appearance().tintColor = UIColor.whiteColor()
		UISearchBar.appearance().translucent = true
		UISearchBar.appearance().placeholder = "Search"
		UISearchBar.appearance().searchBarStyle = UISearchBarStyle.Prominent
		
		if #available(iOS 9.0, *) {
			UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).backgroundColor = UIColor.tempoDarkRed
			UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Book", size: 14.0)!], forState: .Normal)
		}
		
		UITableView.appearance().backgroundColor = UIColor.tempoDarkGray
		UITableView.appearance().separatorColor = UIColor.clearColor()
		UITableView.appearance().separatorStyle = .None
		UITableView.appearance().sectionHeaderHeight = 0
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().rowHeight = 96
		
		UITableViewCell.appearance().backgroundColor = UIColor.tempoDarkGray
		
		// User defined appearances
		PostButton.appearance().backgroundColor = UIColor.tempoLightRed
		SearchPostView.appearance().backgroundColor = UIColor.tempoLightGray
	}
}