//
//  SettingsScrollViewController.swift
//  Tempo
//
//  Created by Keivan Shahida on 4/15/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit
import FBSDKShareKit

class SettingsScrollViewController: UIViewController, UIScrollViewDelegate {
	
	static let sharedInstance = SettingsScrollViewController()
	
	static let registeredForRemotePushNotificationsKey = "SettingsViewController.registeredForRemotePushNotificationsKey"
	static let presentedAlertForRemotePushNotificationsKey = "SettingsViewController.presentedAlertForRemotePushNotificationsKey"
	
	let buttonHeight: CGFloat = 50
	var playerCenter = PlayerCenter.sharedInstance
	
	let spotifyDescription = "Log in to allow Tempo to add songs your find to your Spotify."
	
	var nameLabel: UILabel!
	var usernameLabel: UILabel!
	
	var initialsLabel: UILabel!
	var profilePicture: UIImageView!
	var initialsView: UIView!
	
	var spotifyTitle: UILabel!
	var spotifyDescriptionLabel: UILabel!
	var spotifyDescriptionView: UIView!
	var loginSpotifyButton: UIButton!
	var logoutSpotifyButton: UIButton!
	var toSpotifyButton: UIButton!
	
	var optionsTitle: UILabel!
	var notificationView: UIView!
	var notificationLabel: UILabel!
	var notificationSwitch: UISwitch!
	var enableMusicView: UIView!
	var enableMusicLabel: UILabel!
	var enableMusicSwitch: UISwitch!
	
	var aboutButton: UIButton!
	var logoutTempoButton: UIButton!
	
	var screenWidth: CGFloat!
	let sectionSpacing: CGFloat = 30
	let viewPadding: CGFloat = 11
	
	let settingsFont = UIFont(name: "AvenirNext-Regular", size: 14.0)!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Settings"
		screenWidth = view.frame.width
		
		let scrollViewHeight = view.frame.height - tabBarHeight - miniPlayerHeight
		let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: scrollViewHeight))
		scrollView.delegate = self
		scrollView.backgroundColor = .backgroundDarkGrey
		scrollView.bounces = false
		view = scrollView
		
		setupSettingsView()
		
		//FIX THIS !!! ALSO TEXT GETTING CUT OFF !!!
		
		updateSpotifyState()
		
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
		profilePicture.layer.masksToBounds = false
		profilePicture.layer.cornerRadius = profilePicture.frame.height/2
		profilePicture.clipsToBounds = true
		
		scrollView.contentSize = CGSize(width: screenWidth, height: 480 + tabBarHeight + miniPlayerHeight + 50)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateSpotifyState()
		notificationSwitch.setOn(User.currentUser.remotePushNotificationsEnabled, animated: false)
		enableMusicSwitch.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		title = "Settings"
		view.backgroundColor = .readCellColor
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
	}
	
	func setupSettingsView(){
		
		//Spotify Section Title
		spotifyTitle = UILabel(frame: CGRect(x: 22, y:  30, width: 52, height: 18))
		spotifyTitle.text = "SPOTIFY"
		spotifyTitle.font = settingsFont
		spotifyTitle.textColor = .sectionTitleGrey
		spotifyTitle.textAlignment = .left
		spotifyTitle.sizeToFit()
		view.addSubview(spotifyTitle)
		
		//Description View
		spotifyDescriptionView = UIView(frame: CGRect(x: 0, y: 59, width: screenWidth, height: 91))
		spotifyDescriptionView.backgroundColor = .tempoDarkGray
		
		spotifyDescriptionLabel = UILabel(frame: CGRect(x: 0, y:  26.5, width: 276, height: 38.5))
		spotifyDescriptionLabel.text = spotifyDescription
		spotifyDescriptionLabel.font = settingsFont
		spotifyDescriptionLabel.textColor = .sectionTitleGrey
		spotifyDescriptionLabel.textAlignment = .center
		spotifyDescriptionLabel.numberOfLines = 2
		spotifyDescriptionLabel.sizeToFit()
		spotifyDescriptionLabel.center.x = spotifyDescriptionView.center.x
		spotifyDescriptionView.addSubview(spotifyDescriptionLabel)

		nameLabel = UILabel(frame: CGRect(x: 86, y:  22, width: 250, height: 24)) //h 22
		nameLabel.text = "Name"
		nameLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
		nameLabel.textColor = .offWhite
		nameLabel.textAlignment = .left
		nameLabel.isHidden = true
		spotifyDescriptionView.addSubview(nameLabel)
		
		usernameLabel = UILabel(frame: CGRect(x: 86, y:  47, width: 200, height: 20))
		usernameLabel.text = "@username"
		usernameLabel.font = settingsFont
		usernameLabel.textColor = .sectionTitleGrey
		usernameLabel.textAlignment = .left
		usernameLabel.isHidden = true
		spotifyDescriptionView.addSubview(usernameLabel)
		
		initialsLabel = UILabel(frame: CGRect(x: 22, y:  37, width: 48, height: 21))
		initialsLabel.text = ""
		initialsLabel.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
		initialsLabel.textColor = .sectionTitleGrey
		initialsLabel.textAlignment = .center
		initialsLabel.sizeToFit()
		spotifyDescriptionView.addSubview(initialsLabel)
		
		initialsView = UIView(frame: CGRect(x: 22, y:  22, width: 48, height: 48))
		spotifyDescriptionView.addSubview(initialsView)
		
		profilePicture = UIImageView(frame: CGRect(x: 22, y:  22, width: 48, height: 48))
		profilePicture.layer.cornerRadius = profilePicture.frame.width / 2.0
		spotifyDescriptionView.addSubview(profilePicture)
		
		view.addSubview(spotifyDescriptionView)
		
		//Login Button
		loginSpotifyButton = UIButton(frame: CGRect(x: 0, y:  151, width: screenWidth, height: 50))
		loginSpotifyButton.setTitleColor(.sectionTitleGrey, for: .normal)
		loginSpotifyButton.addTarget(self, action: #selector(loginToSpotify), for: .touchUpInside)
		loginSpotifyButton.setTitle("Log In to Spotify", for: .normal)
		loginSpotifyButton.titleLabel?.font = settingsFont
		loginSpotifyButton.backgroundColor = .tempoDarkGray
		loginSpotifyButton.center.x = view.center.x
		view.addSubview(loginSpotifyButton)
		
		//Log out Button
		logoutSpotifyButton = UIButton(frame: CGRect(x: 0, y:  151, width: screenWidth, height: 50))
		logoutSpotifyButton.setTitleColor(.sectionTitleGrey, for: .normal)
		logoutSpotifyButton.addTarget(self, action: #selector(logOutSpotify), for: .touchUpInside)
		logoutSpotifyButton.setTitle("Log Out of Spotify", for: .normal)
		logoutSpotifyButton.titleLabel?.font = settingsFont
		logoutSpotifyButton.backgroundColor = .tempoDarkGray
		logoutSpotifyButton.center.x = view.center.x
		view.addSubview(logoutSpotifyButton)
		
		//Options Section Title
		optionsTitle = UILabel(frame: CGRect(x: 22, y:  loginSpotifyButton.frame.origin.y + loginSpotifyButton.frame.height + sectionSpacing, width: 62.5, height: 20))
		optionsTitle.text = "OPTIONS"
		optionsTitle.font = settingsFont
		optionsTitle.textColor = .sectionTitleGrey
		optionsTitle.textAlignment = .left
		optionsTitle.sizeToFit()
		view.addSubview(optionsTitle)
		
		//Notifications View
		notificationView = UIView(frame: CGRect(x: 0, y: optionsTitle.frame.origin.y + optionsTitle.frame.height + viewPadding, width: screenWidth, height: 50))
		notificationView.backgroundColor = .tempoDarkGray
		
		notificationLabel = UILabel(frame: CGRect(x: 22, y:  15, width: 128, height: 20))
		notificationLabel.text = "Enable Notifications"
		notificationLabel.font = settingsFont
		notificationLabel.textColor = .sectionTitleGrey
		notificationLabel.textAlignment = .left
		notificationLabel.sizeToFit()
		notificationView.addSubview(notificationLabel)
		
		notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
		notificationSwitch.onTintColor = .tempoRed
		notificationSwitch.addTarget(self, action: #selector(toggledNotifications(_:)), for: .valueChanged)
		notificationView.addSubview(notificationSwitch)
		
		view.addSubview(notificationView)
		
		let centerNotificationSwitchY = NSLayoutConstraint(item: notificationSwitch, attribute: .centerY, relatedBy: .equal,toItem: self.notificationView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		
		let trailingNotificationSwitchConstraints = NSLayoutConstraint(item: notificationSwitch, attribute: .trailingMargin, relatedBy: .equal, toItem: self.notificationView, attribute: .trailingMargin, multiplier: 1.0, constant: -15)
		
		notificationSwitch.translatesAutoresizingMaskIntoConstraints = false;
		self.view.addConstraints([centerNotificationSwitchY, trailingNotificationSwitchConstraints])
		
		//Enable Music View
		enableMusicView = UIView(frame: CGRect(x: 0, y: notificationView.frame.origin.y + notificationView.frame.height + 1, width: screenWidth, height: 50))
		enableMusicView.backgroundColor = .tempoDarkGray

		enableMusicLabel = UILabel(frame: CGRect(x: 22, y:  15, width: 166, height: 20))
		enableMusicLabel.text = "Enable Music On App Exit"
		enableMusicLabel.font = settingsFont
		enableMusicLabel.textColor = .sectionTitleGrey
		enableMusicLabel.textAlignment = .left
		enableMusicLabel.sizeToFit()
		enableMusicView.addSubview(enableMusicLabel)
		
		enableMusicSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
		enableMusicSwitch.onTintColor = .tempoRed
		enableMusicSwitch.addTarget(self, action: #selector(toggledMusicOnExit(_:)), for: .valueChanged)
		enableMusicView.addSubview(enableMusicSwitch)
		
		view.addSubview(enableMusicView)
		
		let centerY = NSLayoutConstraint(item: enableMusicSwitch, attribute: .centerY, relatedBy: .equal, toItem: self.enableMusicView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		
		let trailingConstraints = NSLayoutConstraint(item: enableMusicSwitch, attribute: .trailingMargin, relatedBy: .equal,  toItem: self.enableMusicView, attribute: .trailingMargin, multiplier: 1.0, constant: -15)
		
		enableMusicSwitch.translatesAutoresizingMaskIntoConstraints = false;
		self.view.addConstraints([trailingConstraints, centerY])
		
		//About Button
		aboutButton = UIButton(frame: CGRect(x: 0, y:  enableMusicView.frame.origin.y + enableMusicView.frame.height + sectionSpacing, width: screenWidth, height: 50))
		aboutButton.setTitleColor(.sectionTitleGrey, for: .normal)
		aboutButton.setTitle("About", for: .normal)
		aboutButton.titleLabel?.font = settingsFont
		aboutButton.backgroundColor = .tempoDarkGray
		aboutButton.center.x = view.center.x
		
		aboutButton.addTarget(self, action: #selector(navigateToAbout), for: .touchUpInside)
		view.addSubview(aboutButton)
		
		//Log out Tempo
		logoutTempoButton = UIButton(frame: CGRect(x: 0, y:  aboutButton.frame.origin.y + aboutButton.frame.height + 1, width: screenWidth, height: 50))
		logoutTempoButton.setTitleColor(.sectionTitleGrey, for: .normal)
		logoutTempoButton.setTitle("Log Out", for: .normal)
		logoutTempoButton.titleLabel?.font = settingsFont
		logoutTempoButton.backgroundColor = .tempoDarkGray
		logoutTempoButton.center.x = view.center.x
		
		logoutTempoButton.addTarget(self, action: #selector(logOutUser), for: .touchUpInside)
		view.addSubview(logoutTempoButton)
		
		toSpotifyButton = UIButton(frame: CGRect(x: 0, y: 59, width: screenWidth, height: 91))
		toSpotifyButton.addTarget(self, action: #selector(goToSpotify(_:)), for: .touchUpInside)
		view.addSubview(toSpotifyButton)
		view.bringSubview(toFront: toSpotifyButton)
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
		playerCenter.getPlayerDelegate()?.didToggleAdd?()
	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		toSpotifyButton.isEnabled = loggedIn
		loginSpotifyButton?.isHidden = loggedIn
		spotifyDescriptionLabel?.isHidden = loggedIn
		profilePicture?.isHidden = !loggedIn
		initialsView.isHidden = !loggedIn
		initialsLabel?.isHidden = !loggedIn
		nameLabel?.isHidden = !loggedIn
		usernameLabel?.isHidden = !loggedIn
		logoutSpotifyButton?.isHidden = !loggedIn
	}
	
	func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify(vc: self) { (success) in
			if success {
				self.updateSpotifyState()
			}
		}
	}
	
	func logOutSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.closeCurrentSpotifySession()
		User.currentUser.currentSpotifyUser = nil
		updateSpotifyState()
	}
	
	func goToSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.openSpotifyURL()
	}
	
	func toggledNotifications(_ sender: UISwitch) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let didRegisterForPushNotifications = UserDefaults.standard.bool(forKey: SettingsScrollViewController.registeredForRemotePushNotificationsKey)
		let didPresentAlertForPushNotifications = UserDefaults.standard.bool(forKey: SettingsScrollViewController.presentedAlertForRemotePushNotificationsKey)
		
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
	
	func toggledMusicOnExit(_ sender: UISwitch) {
		let enabled = UserDefaults.standard.bool(forKey: "music_on_off")
		UserDefaults.standard.set(!enabled, forKey: "music_on_off")
		sender.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: true)
	}
	
	//!!!
	
	// TO DO: CREATE FUNCTION TO CHANGE BUTTON TITLE OPACITY !!!
	
	//!!!
	
	func navigateToAbout() {
		navigationController?.pushViewController(AboutViewController.sharedInstance, animated: true)
	}
	
	func logOutUser() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		PlayerCenter.sharedInstance.resetPlayerCells()
		FBSDKAccessToken.setCurrent(nil)
		appDelegate.toggleRootVC()
		appDelegate.feedVC.refreshNeeded = true
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
}
