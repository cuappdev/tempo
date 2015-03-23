//
//  ViewController.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/8/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let options: UISegmentedControl = UISegmentedControl(items: ["Songs", "Users"])
    
    var childVC2 = TrendingViewController()
    var childVC1 = FeedViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        options.selectedSegmentIndex = 0
        options.tintColor = UIColor.grayColor()
        options.addTarget(self, action: "switchTable", forControlEvents: .ValueChanged)
        navigationItem.titleView = options
    }

    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.translucent = true
        
        addChildViewController(childVC1)
        view.addSubview(childVC1.view)
        
        // Arbitrary additions for SWRevealVC
        revealViewController().panGestureRecognizer()
        revealViewController().tapGestureRecognizer()
    }
    
    func switchTable() {
        if (options.selectedSegmentIndex == 1 && childViewControllers[0] as NSObject == childVC1) {
            childVC1.view.removeFromSuperview() //Removes it from view
            childVC1.removeFromParentViewController() //Removes it as child
            addChildViewController(childVC2) //Adds as child
            view.addSubview(childVC2.view) //Adds to view
        } else if (options.selectedSegmentIndex == 0 && childViewControllers[0] as NSObject == childVC2) {
            childVC2.view.removeFromSuperview()
            childVC2.removeFromParentViewController()
            addChildViewController(childVC1)
            view.addSubview(childVC1.view)
        }
    }
}
