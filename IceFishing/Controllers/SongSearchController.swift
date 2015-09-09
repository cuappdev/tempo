//
//  SongSearchController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/8/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SongSearchController: UISearchController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override var searchBar: UISearchBar {
		let bar = super.searchBar
		bar.frame = CGRectMake(0, 0, self.view.frame.size.width, 60)
		return bar
	}

}
