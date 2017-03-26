//
//  AppDelegate.swift
//  Tempo
//
//  Created by Lucas Derraugh on 3/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SWRevealViewController
import Haneke
import MediaPlayer

extension URL {
	func getQueryItemValueForKey(_ key: String) -> AnyObject? {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
		guard let queryItems = components.queryItems else { return nil }
		return queryItems.filter { $0.name == key }.first?.value as AnyObject?
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SWRevealViewControllerDelegate, LoginFlowViewControllerDelegate {
	
	var window: UIWindow?
	let tabBarVC = TabBarController()
	let feedVC = FeedViewController()
	let searchVC = SearchViewController()
	let usersVC = UsersViewController()
	let profileVC = ProfileViewController()
	let likedVC = LikedTableViewController()
	let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
	let aboutVC = AboutViewController()
	
	let playerCenter = PlayerCenter.sharedInstance
	
	var feedNavigationController: UINavigationController!
	var searchNavigationController: UINavigationController!
	var usersNavigationController: UINavigationController!
	var likedNavigationController: UINavigationController!
	var settingsNavigationController: UINavigationController!
	
	let transparentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//	let navigationController = PlayerNavigationController()
	
	var loginFlowViewController: LoginFlowViewController?

	// Saved shortcut item used as a result of an app launch, used later when app is activated.
	var launchedShortcutItem: AnyObject?

	var firstViewController: UIViewController!
	var resetFirstVC = true
	
	var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		URLCache.shared = Foundation.URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		
		feedVC.playerCenter = playerCenter
		likedVC.playerCenter = playerCenter
		searchVC.playerCenter = playerCenter
		settingsVC.playerCenter = playerCenter
		
		feedNavigationController = UINavigationController(rootViewController: feedVC)
		searchNavigationController = UINavigationController(rootViewController: searchVC)
		usersNavigationController = UINavigationController(rootViewController: usersVC)
		likedNavigationController = UINavigationController(rootViewController: likedVC)
		settingsNavigationController = UINavigationController(rootViewController: settingsVC)
		
		// Styling reveal controller
//		revealVC.rearViewRevealWidth = DeviceType.IS_IPHONE_5_OR_LESS ? 260 : 300
//		revealVC.frontViewShadowColor = .revealShadowBlack
//		revealVC.frontViewShadowRadius = 14
//		revealVC.frontViewShadowOffset = CGSize(width: -15, height: 0)
//		revealVC.frontViewShadowOpacity = 0.7
		
		// Set up navigation bar divider
//		let navigationBar = navigationController.navigationBar
//		let navigationSeparator = UIView(frame: CGRect(x: 0, y: navigationBar.frame.size.height - 0.5, width: navigationBar.frame.size.width, height: 0.5))
//		navigationSeparator.backgroundColor = .searchBackgroundRed
//		navigationSeparator.isOpaque = true
//		navigationController.navigationBar.addSubview(navigationSeparator)
		
		StyleController.applyStyles()
		UIApplication.shared.statusBarStyle = .lightContent
		
		// Set up Spotify auth
		SPTAuth.defaultInstance().clientID = "0bc3fa31e7b141ed818f37b6e29a9e85"
		SPTAuth.defaultInstance().redirectURL = NSURL(string: "tempo-login://callback") as URL!
		SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifyUserDefaultsKey"
		SPTAuth.defaultInstance().requestedScopes = [
			SPTAuthPlaylistReadPrivateScope,
			SPTAuthPlaylistModifyPublicScope,
			SPTAuthPlaylistModifyPrivateScope,
			SPTAuthUserLibraryReadScope,
			SPTAuthUserLibraryModifyScope
		]
		
		if SPTAuth.defaultInstance().session != nil && SPTAuth.defaultInstance().session.isValid() {
			SpotifyController.sharedController.setSpotifyUser(SPTAuth.defaultInstance().session.accessToken, completion: nil)
			User.currentUser.currentSpotifyUser?.savedTracks = UserDefaults.standard.dictionary(forKey: User.currentUser.currentSpotifyUser!.savedTracksKey) as [String : AnyObject]? ?? [:]
		}

//		window = UIWindow(frame: UIScreen.main.bounds)
//		window!.backgroundColor = UIColor.tempoLightGray
//		window!.makeKeyAndVisible()
//		window?.tintColor = .tempoRed
		
		FBSDKProfile.enableUpdates(onAccessTokenChange: true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		// Check if it's launched from Quick Action
		var shouldPerformAdditionalDelegateHandling = true
		if #available(iOS 9.0, *) {
			if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
				launchedShortcutItem = shortcutItem
				shouldPerformAdditionalDelegateHandling = false
				resetFirstVC = false
			}
		}
		
		if let facebookLoginToken = FBSDKAccessToken.current()?.tokenString {
			FacebookLoginViewController.retrieveCurrentFacebookUserWithAccessToken(token: facebookLoginToken, completion: nil)
		}
		
		setFirstVC()
		setupTabBar()
		
		// Prepare to play audio
		_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		
		return shouldPerformAdditionalDelegateHandling
	}
	
	func didFinishLoggingIn() {
		if !UserDefaults.standard.bool(forKey: SettingsViewController.presentedAlertForRemotePushNotificationsKey) {
			registerForRemotePushNotifications()
		}
//		setupTabBar()
	}
	
	func setupTabBar() {
		tabBarVC.transparentTabBarEnabled = true
		tabBarVC.numberOfTabs = 5
		tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "FeedSidebarIcon"), forTabAtIndex: 0)
		tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "FeedSidebarIcon"), forTabAtIndex: 0)
		tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "PeopleSidebarIcon"), forTabAtIndex: 1)
		tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "PeopleSidebarIcon"), forTabAtIndex: 1)
		tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "AddIcon"), forTabAtIndex: 2)
		tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "AddIcon"), forTabAtIndex: 2)
		tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "LikedSidebarButton"), forTabAtIndex: 3)
		tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "LikedSidebarButton"), forTabAtIndex: 3)
		tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "SettingsSidebarIcon"), forTabAtIndex: 4)
		tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "SettingsSidebarIcon"), forTabAtIndex: 4)
		
		tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
			self.tabBarVC.present(self.feedNavigationController, animated: false, completion: nil)
		}, forTabAtIndex: 0)
		
		tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
			self.tabBarVC.present(self.usersNavigationController, animated: false, completion: nil)
		}, forTabAtIndex: 1)
		
		tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
			self.tabBarVC.present(self.searchNavigationController, animated: false, completion: nil)
		}, forTabAtIndex: 2)
		
		tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
			self.tabBarVC.present(self.likedNavigationController, animated: false, completion: nil)
		}, forTabAtIndex: 3)
		
		tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
			self.tabBarVC.present(self.settingsNavigationController, animated: false, completion: nil)
		}, forTabAtIndex: 4)
		
		playerCenter.setup()
		tabBarVC.addAccessoryViewController(accessoryViewController: playerCenter)
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.backgroundColor = UIColor.tempoLightGray
		window!.makeKeyAndVisible()
		window?.tintColor = .tempoRed
		window?.rootViewController = tabBarVC
	}
	
	func setFirstVC() {
		if #available(iOS 9.0, *) {
			if let shortcutItem = launchedShortcutItem as? UIApplicationShortcutItem {
				switch (shortcutItem.type) {
				case ShortcutIdentifier.Post.type:
					firstViewController =  feedVC
				case ShortcutIdentifier.PeopleSearch.type:
					firstViewController =  searchVC
				case ShortcutIdentifier.Liked.type:
					firstViewController = likedVC
				case ShortcutIdentifier.Profile.type:
					firstViewController =  profileVC
				default:
					firstViewController = feedVC
				}
				return
			}
		}
		firstViewController = feedVC
	}
		
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		
		// Handle Spotify authentication
		if SPTAuth.defaultInstance().canHandle(url) {
			if let authVC = SpotifyController.sharedController.authViewController {
				// Parse url to a session object
				SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, spotifySession) in
					// Dismiss auth window
					authVC.presentingViewController?.dismiss(animated: true, completion: nil)
					SpotifyController.sharedController.authViewController = nil
					
					if let err = error {
						print("Spotify auth error: \(err)")
					} else if let session = spotifySession {
						let (accessToken, expirationDate) = (session.accessToken, session.expirationDate)
						
						SpotifyController.sharedController.setSpotifyUser(accessToken!, completion: nil)
						SPTAuth.defaultInstance().session = SPTSession(userName: User.currentUser.currentSpotifyUser?.username, accessToken: accessToken, expirationDate: expirationDate)
						
						if let currentVC = self.window?.rootViewController as? LoginFlowViewController {
							currentVC.spotifyLoginViewController.setSpotifyUserAndContinue()
						}
					}
				})
			}
			return true
		}
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		if !UserDefaults.standard.bool(forKey: "music_on_off"){
			playerCenter.togglePause()
			let center = MPNowPlayingInfoCenter.default()
			UIApplication.shared.endReceivingRemoteControlEvents()
			center.nowPlayingInfo = nil
		}
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		if let _ = playerCenter.getCurrentPost() {
			playerCenter.getPostView()?.updatePlayingStatus()
		}
	}
	
	// MARK: - SWRevealDelegate
	
//	func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
//		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//		if position == .left {
//			if let _ = transparentView.superview {
//				transparentView.removeGestureRecognizer(revealVC.panGestureRecognizer())
//				transparentView.removeFromSuperview()
//			}
//			revealController.frontViewController.view.addGestureRecognizer(revealVC.panGestureRecognizer())
//			revealController.frontViewController.revealViewController().tapGestureRecognizer()
//		} else {
//			revealController.frontViewController.view.removeGestureRecognizer(revealVC.panGestureRecognizer())
//			transparentView.addGestureRecognizer(revealVC.panGestureRecognizer())
//			navigationController.view.addSubview(transparentView)
//		}
//		//Notify any hamburger menus that the menu is being toggled
//		NotificationCenter.default.post(name: Notification.Name(rawValue: RevealControllerToggledNotification), object: revealController)
//	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		FBSDKAppEvents.activateApp()
		
		if #available(iOS 9.0, *) {
			guard let shortcut = launchedShortcutItem else { return }

//			if FBSDKAccessToken.current() != nil {
//				let _ = handleShortcutItem(shortcut as! UIApplicationShortcutItem)
//				launchedShortcutItem = nil
//			}
		}
	}
	
	// MARK: - Force Touch Shortcut
	
//	@available(iOS 9.0, *)
//	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//		let handleShortcutItem = self.handleShortcutItem(shortcutItem)
//		completionHandler(handleShortcutItem)
//	}
	
	enum ShortcutIdentifier: String {
		case Post
		case PeopleSearch
		case Liked
		case Profile
		
		init?(fullType: String) {
			guard let last = fullType.components(separatedBy: ".").last else {return nil}
			self.init(rawValue: last)
		}
	
		var type: String {
			return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
		}
	}
	
	//MARK: - Remote Push Notifications
	
	static let remotePushNotificationsDeviceTokenKey = "AppDelegate.remotePushNotificationsDeviceTokenKey"
	
	func registerForRemotePushNotifications() {
		UserDefaults.standard.set(true, forKey: SettingsViewController.presentedAlertForRemotePushNotificationsKey)
		DispatchQueue.main.async {
			let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
			UIApplication.shared.registerUserNotificationSettings(settings)
		}
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		UserDefaults.standard.set(deviceToken, forKey: AppDelegate.remotePushNotificationsDeviceTokenKey)
		API.sharedAPI.registerForRemotePushNotificationsWithDeviceToken(deviceToken, completion: { _ in } )
	}
	
	func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		application.registerForRemoteNotifications()
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		print("RECIEVED PUSH NOTIFICATION")
		print(userInfo)
	}

}
