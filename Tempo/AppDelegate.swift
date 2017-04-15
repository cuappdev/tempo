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
	let tabBarVC = TabBarController.sharedInstance
	let feedVC = FeedViewController()
	let searchVC = SearchViewController()
	let usersVC = UsersViewController()
	let profileVC = ProfileViewController()
	let likedVC = LikedTableViewController()
	let notifVC = NotificationCenterViewController()
	
	let playerCenter = PlayerCenter.sharedInstance
	
	var feedNavigationController: UINavigationController!
	var searchNavigationController: UINavigationController!
	var usersNavigationController: UINavigationController!
	var likedNavigationController: UINavigationController!
	var profileNavigationController: UINavigationController!
	var notificationNavigationController: UINavigationController!
	
	var loginFlowViewController: LoginFlowViewController?

	var resetFirstVC = true
	
	var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		URLCache.shared = Foundation.URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		
		// Connect all the delegates
		searchVC.delegate = feedVC
		
		feedNavigationController = UINavigationController(rootViewController: feedVC)
		searchNavigationController = UINavigationController(rootViewController: searchVC)
		usersNavigationController = UINavigationController(rootViewController: usersVC)
		likedNavigationController = UINavigationController(rootViewController: likedVC)
		profileNavigationController = UINavigationController(rootViewController: profileVC)
		notificationNavigationController = UINavigationController(rootViewController: notifVC)
		
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
		
		FBSDKProfile.enableUpdates(onAccessTokenChange: true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		if let facebookLoginToken = FBSDKAccessToken.current()?.tokenString {
			FacebookLoginViewController.retrieveCurrentFacebookUserWithAccessToken(token: facebookLoginToken, completion: { _ in
				self.profileVC.user = User.currentUser
				if self.profileVC.isViewLoaded {
					self.profileVC.setupUserUI()
				}
			})
		}
		
		toggleRootVC()
		
		// Check if launched via push notification
		if let options = launchOptions {
			print(options)
			if options.description.lowercased().contains("liked a song") {
				let postHistoryVC = profileVC.postHistoryVC
				postHistoryVC.posts = profileVC.posts
				postHistoryVC.postedDates = profileVC.postedDates
				postHistoryVC.filterPostedDatesToSections(profileVC.postedDates)
				postHistoryVC.songLikes = profileVC.postedLikes
				tabBarVC.present(postHistoryVC, animated: false)
			} else if options.description.lowercased().contains("following") {
				
			}
		}
		
		// Prepare to play audio
		_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		
		return true
	}
	
	func didFinishLoggingIn() {
		if !UserDefaults.standard.bool(forKey: SettingsViewController.presentedAlertForRemotePushNotificationsKey) {
			registerForRemotePushNotifications()
		}
		toggleRootVC()
	}
	
	func toggleRootVC() {
		launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
		if FBSDKAccessToken.current() == nil {
			loginFlowViewController = LoginFlowViewController()
			loginFlowViewController?.delegate = self
			window?.rootViewController = loginFlowViewController
		} else {
			tabBarVC.transparentTabBarEnabled = true
			tabBarVC.numberOfTabs = 5
			tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "PassiveTabBarFeed"), forTabAtIndex: 0)
			tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "ActiveTabBarFeed"), forTabAtIndex: 0)
			tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "PassiveTabBarSearch"), forTabAtIndex: 1)
			tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "ActiveTabBarSearch"), forTabAtIndex: 1)
			tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "TabBarPost"), forTabAtIndex: 2)
			tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "TabBarPost"), forTabAtIndex: 2)
			tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "PassiveTabBarNotifications"), forTabAtIndex: 3)
			tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "ActiveTabBarNotifications"), forTabAtIndex: 3)
			tabBarVC.setUnselectedImage(image: #imageLiteral(resourceName: "PassiveTabBarProfile"), forTabAtIndex: 4)
			tabBarVC.setSelectedImage(image: #imageLiteral(resourceName: "ActiveTabBarProfile"), forTabAtIndex: 4)
			
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
				self.tabBarVC.present(self.notificationNavigationController, animated: false, completion: nil)
			}, forTabAtIndex: 3)
			
			tabBarVC.addBlockToExecuteOnTabBarButtonPress(block: {
				self.tabBarVC.present(self.profileNavigationController, animated: false, completion: nil)
			}, forTabAtIndex: 4)
			
			tabBarVC.addAccessoryViewController(accessoryViewController: playerCenter)
			tabBarVC.programmaticallyPressTabBarButton(atIndex: 0)
			
			window = UIWindow(frame: UIScreen.main.bounds)
			window!.backgroundColor = UIColor.tempoLightGray
			window!.makeKeyAndVisible()
			window?.tintColor = .tempoRed
			window?.rootViewController = tabBarVC
		}
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
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		FBSDKAppEvents.activateApp()
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
		switch application.applicationState {
		case .active:
			tabBarVC.showNotificationBanner(userInfo)
		default:
			return
		}
		
	}

}
