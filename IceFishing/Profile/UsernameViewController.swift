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
    
    @IBAction func createUser(sender: UIButton) {
        
		guard let username = usernameTextField.text else { print("No Username"); return}
		
		let charSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").invertedSet
		let invalidChars = username.rangeOfCharacterFromSet(charSet)
		
		if invalidChars == nil {
			// Username contains only valid characters
			API.sharedAPI.usernameIsValid(username) { success in
				if success {
					// Username available
					User.currentUser.username = username
					API.sharedAPI.updateCurrentUser(username) { user in }
					let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
					appDelegate.toggleRootVC()
				} else {
					// Username already taken (prompt user with error alert in UsernameVC)
					let errorAlert = UIAlertController(title: "Sorry!", message: "Username is taken.", preferredStyle: UIAlertControllerStyle.Alert)
					errorAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
					self.presentViewController(errorAlert, animated: true, completion: nil)
					self.clearTextField()
				}
			}
		} else {
			// Username contains some invalid characters
			let errorAlert = UIAlertController(title: "Sorry!", message: "Only underscores and alphanumeric characters are allowed.", preferredStyle: UIAlertControllerStyle.Alert)
			errorAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(errorAlert, animated: true, completion: nil)
			self.clearTextField()
		}
	
    }
	
    func clearTextField() {
        usernameTextField.text = ""
    }
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
