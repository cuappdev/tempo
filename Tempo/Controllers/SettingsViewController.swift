//
//  SettingsViewController.swift
//  Tempo
//
//  Created by Keivan Shahida on 11/20/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import FBSDKShareKit

class SettingsViewController: UIViewController {
	
	static let sharedInstance = SettingsViewController()
	
	let buttonHeight: CGFloat = 50
	var playerCenter = PlayerCenter.sharedInstance
	
	@IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var loginToSpotifyButton: UIButton!
	@IBOutlet weak var goToSpotifyButton: UIButton!
	@IBOutlet weak var logOutSpotifyButton: UIButton!
	@IBOutlet weak var toggleNotifications: UISwitch!
	@IBOutlet weak var useLabel: UILabel!
	@IBOutlet weak var logOutButtonHeight: NSLayoutConstraint!
	@IBOutlet weak var toggleMusicOnExit: UISwitch!
	
	static let registeredForRemotePushNotificationsKey = "SettingsViewController.registeredForRemotePushNotificationsKey"
	static let presentedAlertForRemotePushNotificationsKey = "SettingsViewController.presentedAlertForRemotePushNotificationsKey"
	var shouldAddHamburger = true
	
	override func viewDidLoad() {
		super.viewDidLoad()

		toggleNotifications.onTintColor = .tempoRed
		toggleMusicOnExit.onTintColor = .tempoRed
		profilePicture.layer.cornerRadius = profilePicture.frame.width / 2.0
		
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
		
		let logoutItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutUser))
		let aboutItem = UIBarButtonItem(image: UIImage(named: "AboutSidebarIcon"), style: .plain, target: self, action: #selector(navigateToAbout))
		navigationItem.rightBarButtonItem = logoutItem
//		navigationItem.leftBarButtonItem = aboutItem
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateSpotifyState()
		toggleNotifications.setOn(User.currentUser.remotePushNotificationsEnabled, animated: false)
		toggleMusicOnExit.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: false)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		title = "Settings"
		view.backgroundColor = .readCellColor
		
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		//add HamburgerMenu by default, unless shouldAddHamburger is explicitly changed
		shouldAddHamburger = true
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		if let session = SPTAuth.defaultInstance().session, session.isValid() {
			SpotifyController.sharedController.setSpotifyUser(session.accessToken, completion: { (success: Bool) in
				DispatchQueue.main.async {
					if let currentSpotifyUser = User.currentUser.currentSpotifyUser {
						self.nameLabel?.text = "\(User.currentUser.firstName) \(User.currentUser.lastName)"
						self.usernameLabel?.text = "@\(currentSpotifyUser.username)"
						self.initialsLabel?.text = setUserInitials(firstName: User.currentUser.firstName, lastName: User.currentUser.lastName)
						self.loggedInToSpotify(session.isValid())
					}
				}
			})
		} else {
			
			loggedInToSpotify(false)
		}
		playerCenter.updateAddButton()
	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		loginToSpotifyButton?.isHidden = loggedIn
		useLabel?.isHidden = loggedIn
		profilePicture?.isHidden = !loggedIn
		initialsView.isHidden = !loggedIn
		initialsLabel?.isHidden = !loggedIn
		nameLabel?.isHidden = !loggedIn
		usernameLabel?.isHidden = !loggedIn
		goToSpotifyButton?.isHidden = !loggedIn
		logOutButtonHeight.constant = loggedIn ? 50 : 0
		logOutSpotifyButton?.isHidden = !loggedIn
	}
	
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify(vc: self) { (success) in
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
	
	@IBAction func toggledMusicOnExit(_ sender: UISwitch) {
		let enabled = UserDefaults.standard.bool(forKey: "music_on_off")
		UserDefaults.standard.set(!enabled, forKey: "music_on_off")
		sender.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: true)
		//add logic to appdelegate to meet user's desired settings
	}
	
	@IBAction func goToSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.openSpotifyURL()
	}
	
	@IBAction func logOutSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.closeCurrentSpotifySession()
		User.currentUser.currentSpotifyUser = nil
		updateSpotifyState()
	}
	
	func logOutUser() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		PlayerCenter.sharedInstance.resetPlayerCells()
		FBSDKAccessToken.setCurrent(nil)
		appDelegate.toggleRootVC()
		appDelegate.feedVC.refreshNeeded = true
	}
	
	func navigateToAbout() {
		navigationController?.pushViewController(AboutViewController.sharedInstance, animated: true)
	}
}
