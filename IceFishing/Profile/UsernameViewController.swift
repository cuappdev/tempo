//
//  UsernameViewController.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController {
 
    var searchNavigationController: UINavigationController!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 181.0 / 255.0, green: 87.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
    }
    
    @IBAction func createUser(sender: UIButton) {
        
        let username = usernameTextField.text as String
        
        API.sharedAPI.usernameIsValid(username) { success in
            if (success) {
                // Username available
                User.currentUser.username = username
                API.sharedAPI.updateCurrentUser(username) { user in }
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.toggleRootVC()
            } else {
                // Username already taken (prompt user with error alert in UsernameVC)
                var errorAlert = UIAlertController(title: "Sorry!", message: "Username is taken.", preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
                self.clearTextField()
            }
        }
    }
    
    func clearTextField() {
        usernameTextField.text = ""
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
