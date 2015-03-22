//
//  ViewController.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/8/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let options: UISegmentedControl = UISegmentedControl(items: ["Songs", "Users"])
    //Segmented Controller
    
    var childVC2 = TrendingVC()
    var childVC1 = FeedVC()
    var containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("ButtonMethod"))
        
        options.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        options.selectedSegmentIndex = 0 //Defaults to the option at index 0
        options.layer.cornerRadius = 7.0
        options.tintColor = UIColor.grayColor()
        navigationItem.titleView = options //Pins it to the top
        options.addTarget(self, action: Selector("SwitchTable"), forControlEvents: UIControlEvents.ValueChanged)
//        self.addChildViewController(childVC1)
//        self.view.addSubview(childVC1.view)
    }

    override func viewDidAppear(animated: Bool) {
         navigationController?.navigationBar.barTintColor = UIColor(red: 220, green: 221, blue: 242, alpha: 1.0)
        
        let navBarHeight: CGFloat = navigationController!.navigationBar.frame.height + 20
        containerView.frame = CGRect(x: 0, y: navBarHeight, width: view.frame.width, height: view.frame.height-navBarHeight)
        //containerView.center = CGPoint(x: view.center.x, y: (view.frame.height - navBarHeight)/2)
        view.addSubview(containerView)
        
        self.addChildViewController(childVC1)
        childVC1.view.frame = containerView.bounds
        childVC1.feedTableView.frame = containerView.bounds
        containerView.addSubview(childVC1.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SwitchTable() {
        if (options.selectedSegmentIndex == 1 && self.childViewControllers[0] as NSObject == childVC1) {
            childVC1.view.removeFromSuperview() //Removes it from view
            childVC1.removeFromParentViewController() //Removes it as child
            self.addChildViewController(childVC2) //Adds as child
            containerView.addSubview(childVC2.view) //Adds to view
        } else if (options.selectedSegmentIndex == 0 && self.childViewControllers[0] as NSObject == childVC2) {
            childVC2.view.removeFromSuperview()
            childVC2.removeFromParentViewController()
            self.addChildViewController(childVC1)
            containerView.addSubview(childVC1.view)
        }
    
    }
    

}
