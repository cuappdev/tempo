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
		
		if username == "" {
			showErrorAlert("Empty field", message: "Username must have at least one character.", actionTitle: "Try again")
		} else if invalidChars != nil {
			// Username contains some invalid characters
			showErrorAlert("Invalid characters", message: "Only underscores and alphanumeric characters are allowed.", actionTitle: "Try again")
		} else {
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
					self.showErrorAlert("Sorry", message: "Username is taken.", actionTitle: "Try again")
				}
			}
		}
	
    }
	
	func showErrorAlert(title: String, message: String, actionTitle: String) {
		let errorAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		errorAlert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
		presentViewController(errorAlert, animated: true, completion: nil)
		usernameTextField.text = ""
	}
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
