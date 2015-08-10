//
//  ViewController+Bar.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 5/5/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import Foundation

extension UIViewController {
    func beginIceFishing() {        
        //—————————————from MAIN VC——————————————————
        navigationItem.title = self.title
        
        // Add hamburger menu to the left side of the navbar
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height * 0.65))
        menuButton.setImage(UIImage(named: "Hamburger-Menu-Icon"), forState: .Normal)
        menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        // Pop out sidebar when hamburger menu tapped
        if revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			revealViewController().panGestureRecognizer()
			revealViewController().tapGestureRecognizer()
        }
    }
}
