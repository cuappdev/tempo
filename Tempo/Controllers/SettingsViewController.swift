//
//  SettingsViewController.swift
//  Tempo
//
//  Created by Keivan Shahida on 11/20/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var loginToSpotifyButton: UIButton!
	@IBOutlet weak var goToSpotifyButton: UIButton!
	@IBOutlet weak var logOutSpotifyButton: UIButton!
	@IBOutlet weak var toggleNotifications: UISwitch!
	@IBOutlet weak var useLabel: UILabel!
	
	let registeredDeviceTokenForRemotePushNotificationsKey = "SettingsViewController.registeredDeviceTokenForRemotePushNotificationsKey"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		toggleNotifications.onTintColor = UIColor.tempoLightRed
		profilePicture.layer.cornerRadius = profilePicture.frame.width / 2.0
		
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		title = "Settings"
		addHamburgerMenu()
	}
	
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				SpotifyController.sharedController.setSpotifyUser(session.accessToken)
				let currentSpotifyUser = User.currentUser.currentSpotifyUser
				self.nameLabel.text = "\(User.currentUser.firstName) \(User.currentUser.lastName)"
				self.usernameLabel.text = "@\(currentSpotifyUser!.username)"
			}
			loggedInToSpotify(session.isValid())
		} else {
			loggedInToSpotify(false)
		}
	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		loginToSpotifyButton.isHidden = loggedIn
		useLabel.isHidden = loggedIn
		
		profilePicture.isHidden = !loggedIn
		nameLabel.isHidden = !loggedIn
		usernameLabel.isHidden = !loggedIn
		goToSpotifyButton.isHidden = !loggedIn
		logOutSpotifyButton.isHidden = !loggedIn
	}
	
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success {
				self.updateSpotifyState()
			}
		}
	}
	
	@IBAction func toggledNotifications(_ sender: UISwitch) {

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		if sender.isOn {
//			appDelegate.registerForRemotePushNotifications()
			
			
		}
		
		API.sharedAPI.toggleRemotePushNotifications(userID: User.currentUser.id, enabled: sender.isOn, completion: { (success: Bool) in
			
			print(success)
			print(User.currentUser.remotePushNotificationsEnabled)
			print(UIApplication.shared.currentUserNotificationSettings)
			
		})
	}
	
	@IBAction func goToSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.openSpotifyURL()
	}
	
	@IBAction func logOutSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.closeCurrentSpotifySession()
		
		updateSpotifyState()
	}
}
