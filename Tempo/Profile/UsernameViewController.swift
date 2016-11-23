//
//  UsernameViewController.swift
//  Tempo
//
//  Created by Manuela Rios on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKShareKit

class UsernameViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
 
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
		let charSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted
		let invalidChars = username.rangeOfCharacter(from: charSet)
		
		if username == "" {
			alertLabel.text = "Username must have at least one character."
			alertLabel.textColor = UIColor.red
		} else if invalidChars != nil { // Username contains some invalid characters
			alertLabel.text = "Only underscores and alphanumeric characters allowed."
			alertLabel.textColor = UIColor.red
		} else { // Username contains only valid characters
			API.sharedAPI.usernameIsValid(username) { success in
				if success { // Username available
					API.sharedAPI.updateCurrentUser(username, didSucceed: { (success) in
						if success {

							let appDelegate = UIApplication.shared.delegate as! AppDelegate
							let spotifyLoginVC = SpotifyLoginViewController(nibName: "SpotifyLoginViewController", bundle: nil)
							appDelegate.window!.rootViewController = spotifyLoginVC
							
						} else {
							self.alertLabel.text = "Username failed to update. Try again."
							self.alertLabel.textColor = .red
						}
					})
				} else { // Username already taken
					self.alertLabel.text = "Username unavailable."
					self.alertLabel.textColor = .red
				}
			}
		}
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initializeTextField()
		continueBtn.layer.cornerRadius = 5
		
		userProfilePicture.layer.borderWidth = 1.5
		userProfilePicture.layer.borderColor = UIColor.white.cgColor
		userProfilePicture.layer.cornerRadius = userProfilePicture.frame.size.height/2
		userProfilePicture.clipsToBounds = true
		nameLabel.text = name
		
		guard let imageUrl = URL(string: "http://graph.facebook.com/\(fbID)/picture?type=large") else { return }
		userProfilePicture.hnk_setImageFromURL(imageUrl)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	func textFieldDidChange(textField: UITextField) {
		if let usernameValue = usernameTextField.text {
			usernameLabel.text = "@\(usernameValue)"
		}
	}
	
	func keyboardWillShow(sender: NSNotification) {
		if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let keyboardHeight = keyboardSize.height
			self.view.frame.origin.y = -keyboardHeight
		}
	}
	
	func keyboardWillHide(sender: NSNotification) {
		self.view.frame.origin.y = 0
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func initializeTextField(){
		usernameTextField.delegate = self
		usernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
		super.touchesBegan(touches, with: event)
	}

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
