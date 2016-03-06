//
//  ProfilePictureViewController.swift
//  IceFishing
//
//  Created by Monica Ong on 2/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ProfilePictureViewController: UIViewController {
	
    @IBOutlet weak var profilePictureView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func exitButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
