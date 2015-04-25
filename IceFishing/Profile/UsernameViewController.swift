//
//  UsernameViewController.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, FBLoginViewDelegate {
 
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createUser(sender: UIButton) {
        //check if username is taken or not by calling doing a GET request to /users/:username 
//        if (username is taken) {
//            prompt user with error alert
//        } else {
//            create a user by doing a POST request to /sessions with parameters of a user object, where a User object is defined by: name,, email, Facebook id, and username
//            }
        
        let feedVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
        presentViewController(feedVC, animated: false, completion: nil)

    }
    
//    var enterUsername: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        println("UsernameViewController!")
//    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        println("username view controller")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
