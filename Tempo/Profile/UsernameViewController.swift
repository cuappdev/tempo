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
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
	
    @IBAction func createUser(sender: UIButton) {
		guard let username = usernameTextField.text else { print("No Username"); return}
		let charSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").invertedSet
		let invalidChars = username.rangeOfCharacterFromSet(charSet)
		
		if username == "" {
			alertLabel.text = "Username must have at least one character."
			alertLabel.textColor = UIColor.redColor()
		} else if invalidChars != nil { // Username contains some invalid characters
			alertLabel.text = "Only underscores and alphanumeric characters allowed."
			alertLabel.textColor = UIColor.redColor()
		} else { // Username contains only valid characters
			API.sharedAPI.usernameIsValid(username) { success in
				if success { // Username available
					API.sharedAPI.updateCurrentUser(username, didSucceed: { (success) in
						if success {
							let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
							appDelegate.launchOnboarding(true)
						} else {
							self.alertLabel.text = "Username failed to update. Try again."
							self.alertLabel.textColor = UIColor.redColor()
						}
					})
				} else { // Username already taken
					self.alertLabel.text = "Username unavailable."
					self.alertLabel.textColor = UIColor.redColor()
				}
			}
		}
    }

	override func viewWillAppear(animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        continueBtn.layer.cornerRadius = 5
		usernameTextField.addTarget(self, action: #selector(UsernameViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
		
		userProfilePicture.layer.borderWidth = 1.5
		userProfilePicture.layer.borderColor = UIColor.whiteColor().CGColor
		userProfilePicture.layer.cornerRadius = userProfilePicture.frame.size.height/2
		userProfilePicture.clipsToBounds = true
		nameLabel.text = name
		
		guard let imageUrl = NSURL(string: "http://graph.facebook.com/\(fbID)/picture?type=large") else { return }
		userProfilePicture.hnk_setImageFromURL(imageUrl)
	}
	
	func textFieldDidChange(textField: UITextField) {
		if let usernameValue = usernameTextField.text {
			usernameLabel.text = "@\(usernameValue)"
		}
	}
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}