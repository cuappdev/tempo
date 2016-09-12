//
//  UsernameViewController.swift
//  Tempo
//
//  Created by Manuela Rios on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKShareKit

class UsernameViewController: UIViewController, UINavigationControllerDelegate {
 
	var fbID: String = ""
	var name: String = ""
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func createUser(sender: UIButton) {
		guard let username = usernameTextField.text else { print("No Username"); return}
		let charSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").invertedSet
		let invalidChars = username.rangeOfCharacterFromSet(charSet)
		
		if username == "" {
			showErrorAlert("Empty field!", message: "Username must have at least one character.", actionTitle: "Try again")
		} else if invalidChars != nil { // Username contains some invalid characters
			showErrorAlert("Invalid characters!", message: "Only underscores and alphanumeric characters are allowed.", actionTitle: "Try again")
		} else { // Username contains only valid characters
			API.sharedAPI.usernameIsValid(username) { success in
				if success { // Username available
					API.sharedAPI.updateCurrentUser(username, didSucceed: { (success) in
						if success {
							let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
							appDelegate.toggleRootVC()
						} else {
							self.showErrorAlert("Sorry!", message: "Username failed to update.", actionTitle: "Try again")
						}
					})
				} else { // Username already taken
					self.showErrorAlert("Sorry!", message: "Username is taken.", actionTitle: "Try again")
				}
			}
		}
    }
	
    @IBAction func logOut(sender: UIButton) {
		FBSDKAccessToken.setCurrentAccessToken(nil)
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.toggleRootVC()
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Enter Your Username"
		
		userProfilePicture.layer.borderWidth = 1.5
		userProfilePicture.layer.borderColor = UIColor.whiteColor().CGColor
		userProfilePicture.layer.cornerRadius = userProfilePicture.frame.size.height/2
		userProfilePicture.clipsToBounds = true
		nameLabel.text = name
		
		guard let imageUrl = NSURL(string: "http://graph.facebook.com/\(fbID)/picture?type=large") else { return }
		userProfilePicture.hnk_setImageFromURL(imageUrl)
	}
	
	func showErrorAlert(title: String, message: String, actionTitle: String) {
		let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		errorAlert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
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
