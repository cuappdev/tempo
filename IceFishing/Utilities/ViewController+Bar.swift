//
//  ViewController+Bar.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

extension UIViewController {
    func beginIceFishing() {        
        //—————————————from MAIN VC——————————————————
        navigationItem.title = self.title
        
        navigationController?.navigationBar.barTintColor = UIColor.iceDarkRed()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.translucent = true
        
        // Add hamburger menu to the left side of the navbar
        var menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height * 0.65))
        menuButton.setImage(UIImage(named: "white-hamburger-menu-Icon"), forState: .Normal)
        menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        // Pop out sidebar when hamburger menu tapped
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Arbitrary additions for SWRevealVC
        revealViewController().panGestureRecognizer()
        revealViewController().tapGestureRecognizer()
        
        //—————————————from MAIN VC——————————————————
        if let tableSelf = self as? UITableViewController {
            tableSelf.tableView.backgroundColor = UIColor.iceDarkGray()
            tableSelf.tableView.separatorColor = UIColor.iceDarkGray()
        }

    }
}
