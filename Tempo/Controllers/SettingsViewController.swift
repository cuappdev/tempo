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
	
	static let registeredForRemotePushNotificationsKey = "SettingsViewController.registeredForRemotePushNotificationsKey"
	static let presentedAlertForRemotePushNotificationsKey = "SettingsViewController.presentedAlertForRemotePushNotificationsKey"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		toggleNotifications.onTintColor = UIColor.tempoLightRed
		profilePicture.layer.cornerRadius = profilePicture.frame.width / 2.0
		
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateSpotifyState()
		toggleNotifications.setOn(User.currentUser.remotePushNotificationsEnabled, animated: false)
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
				SpotifyController.sharedController.setSpotifyUser(session.accessToken, completion: { (success: Bool) in
					
					DispatchQueue.main.async {
						if let currentSpotifyUser = User.currentUser.currentSpotifyUser {
							self.nameLabel?.text = "\(User.currentUser.firstName) \(User.currentUser.lastName)"
							self.usernameLabel?.text = "@\(currentSpotifyUser.username)"
							self.loggedInToSpotify(session.isValid())
						}
					}
				})
			}
		} else {
			loggedInToSpotify(false)
		}
	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		loginToSpotifyButton?.isHidden = loggedIn
		useLabel?.isHidden = loggedIn
		
		profilePicture?.isHidden = !loggedIn
		nameLabel?.isHidden = !loggedIn
		usernameLabel?.isHidden = !loggedIn
		goToSpotifyButton?.isHidden = !loggedIn
		logOutSpotifyButton?.isHidden = !loggedIn
	}
	
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success {
				self.updateSpotifyState()
			}
		}
	}
	
	func showPromptIfPushNotificationsDisabled() {
		
		let alertController = UIAlertController(title: "Push Notifications Disabled", message: "Please enable push notifications for Tempo in the Settings app", preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
			if let url = URL(string:UIApplicationOpenSettingsURLString) {
				UIApplication.shared.openURL(url)
			}
		})
		
		alertController.addAction(okAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func toggledNotifications(_ sender: UISwitch) {
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let didRegisterForPushNotifications = UserDefaults.standard.bool(forKey: SettingsViewController.registeredForRemotePushNotificationsKey)
		let didPresentAlertForPushNotifications = UserDefaults.standard.bool(forKey: SettingsViewController.presentedAlertForRemotePushNotificationsKey)

		if didPresentAlertForPushNotifications && !UIApplication.shared.isRegisteredForRemoteNotifications && sender.isOn {
			sender.setOn(false, animated: false)
			showPromptIfPushNotificationsDisabled()
			return
		}
		
		if sender.isOn && UserDefaults.standard.data(forKey: AppDelegate.remotePushNotificationsDeviceTokenKey) == nil {
			appDelegate.registerForRemotePushNotifications()
			return
		}
		
		if let deviceToken = UserDefaults.standard.data(forKey: AppDelegate.remotePushNotificationsDeviceTokenKey), !didRegisterForPushNotifications {
			API.sharedAPI.registerForRemotePushNotificationsWithDeviceToken(deviceToken, completion: { _ in })
			return
		}
		
		let enabled = sender.isOn
		
		API.sharedAPI.toggleRemotePushNotifications(userID: User.currentUser.id, enabled: enabled, completion: { (success: Bool) in
			
			if !success {
				sender.setOn(!enabled, animated: true)
			}
			
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
