//
//  SearchTrackViewController.swift
//  IceFishing
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

class SearchTrackViewController : UIViewController, UISearchControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.definesPresentationContext = true
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    func presentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}