//
//  UsernameViewController.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, FBLoginViewDelegate {
 
    var searchNavigationController: UINavigationController!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 181.0 / 255.0, green: 87.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    @IBAction func createUser(sender: UIButton) {
        
        let username = usernameTextField.text
        
        // TODO: Check if username is taken or not by calling a GET request to /users/:username
        /*
            if (username is taken) {
                Prompt user with error alert in UsernameVC
            } else {
                Create a user by doing a POST request to /sessions with parameters of a user object(name, email, FB id, username)
            }
        */
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        println("username view controller")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
