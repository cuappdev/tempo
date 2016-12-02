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
	let revealVC = SWRevealViewController()
	let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
	let feedVC = FeedViewController()
	let searchVC = SearchViewController()
	let usersVC = UsersViewController()
	let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
	let likedVC = LikedTableViewController()
	let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
	let aboutVC = AboutViewController()
	let transparentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
	let navigationController = PlayerNavigationController()
	
	var loginFlowViewController: LoginFlowViewController?

	// Saved shortcut item used as a result of an app launch, used later when app is activated.
	var launchedShortcutItem: AnyObject?

	var firstViewController: UIViewController!
	var resetFirstVC = true
	
	var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		URLCache.shared = Foundation.URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		
		// Set up navigation bar divider
		let navigationBar = navigationController.navigationBar
		let navigationSeparator = UIView(frame: CGRect(x: 0, y: navigationBar.frame.size.height - 0.5, width: navigationBar.frame.size.width, height: 0.5))
		navigationSeparator.backgroundColor = .searchBackgroundRed
		navigationSeparator.isOpaque = true
		navigationController.navigationBar.addSubview(navigationSeparator)
		
		StyleController.applyStyles()
		UIApplication.shared.statusBarStyle = .lightContent
		
		SPTAuth.defaultInstance().clientID = "0bc3fa31e7b141ed818f37b6e29a9e85"
		SPTAuth.defaultInstance().redirectURL = NSURL(string: "tempologin://callback") as URL!

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
			User.currentUser.currentSpotifyUser?.savedTracks = UserDefaults.standard.dictionary(forKey: "savedTracks") as [String : AnyObject]? ?? [:]
		}

		window = UIWindow(frame: UIScreen.main.bounds)
		window!.backgroundColor = UIColor.tempoLightGray
		window!.makeKeyAndVisible()
		window?.tintColor = .tempoRed
		
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
		toggleRootVC()
		
		return shouldPerformAdditionalDelegateHandling
	}
	
	func didFinishLoggingIn() {
		toggleRootVC()
	}
	
	func toggleRootVC() {
		launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
		if FBSDKAccessToken.current() == nil {
			loginFlowViewController = LoginFlowViewController()
			loginFlowViewController?.delegate = self
			window?.rootViewController = loginFlowViewController
		} else {
			if resetFirstVC {
				navigationController.setViewControllers([firstViewController], animated: false)
			}
			revealVC.setFront(navigationController, animated: false)
			revealVC.setRear(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "feed-sidebar-icon")),
				SideBarElement(title: "People", viewController: usersVC, image: UIImage(named: "people-sidebar-icon")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "liked-sidebar-icon")),
				SideBarElement(title: "Settings", viewController: settingsVC, image: UIImage(named: "spotify-sidebar-icon")),
				SideBarElement(title: "About", viewController: aboutVC, image: UIImage(named: "about-sidebar-icon"))
			]
			sidebarVC.selectionHandler = { [weak self] viewController in
				if let viewController = viewController {
					if let front = self?.revealVC.frontViewController {
						if viewController == front {
							self?.revealVC.setFrontViewPosition(.left, animated: true)
							return
						}
					}
					self?.navigationController.setViewControllers([viewController], animated: false)
					self?.revealVC.setFrontViewPosition(.left, animated: true)
				}
			}
			
			revealVC.delegate = self
			window!.rootViewController = revealVC
		}
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
		if url.absoluteString.contains(SPTAuth.defaultInstance().redirectURL.absoluteString) {
			SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { [weak self] error, session in
				if error != nil {
					print("*** Auth error: \(error)")
				} else {
					let accessToken = url.getQueryItemValueForKey("access_token") as? String
					let unixExpirationDate = url.getQueryItemValueForKey("expires_at") as? String
					let expirationDate = Date(timeIntervalSince1970: Double(unixExpirationDate!)!)
					
					SpotifyController.sharedController.setSpotifyUser(accessToken!, completion: nil)
					SPTAuth.defaultInstance().session = SPTSession(userName: User.currentUser.currentSpotifyUser?.username, accessToken: accessToken, expirationDate: expirationDate)
					self?.settingsVC.updateSpotifyState()
					if let currentVC = self?.window?.rootViewController as? SpotifyLoginViewController {
						currentVC.setSpotifyUserAndContinue()
					}
				}
			}
			return true
		}
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	// MARK: - SWRevealDelegate
	
	func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		if position == .left {
			if let _ = transparentView.superview {
				transparentView.removeGestureRecognizer(revealVC.panGestureRecognizer())
				transparentView.removeFromSuperview()
			}
			revealController.frontViewController.view.addGestureRecognizer(revealVC.panGestureRecognizer())
			revealController.frontViewController.revealViewController().tapGestureRecognizer()
		} else {
			revealController.frontViewController.view.removeGestureRecognizer(revealVC.panGestureRecognizer())
			transparentView.addGestureRecognizer(revealVC.panGestureRecognizer())
			navigationController.view.addSubview(transparentView)
		}
		//Notify any hamburger menus that the menu is being toggled
		NotificationCenter.default.post(name: Notification.Name(rawValue: RevealControllerToggledNotificaiton), object: revealController)
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		FBSDKAppEvents.activateApp()
		
		if #available(iOS 9.0, *) {
			guard let shortcut = launchedShortcutItem else { return }

			if FBSDKAccessToken.current() != nil {
				let _ = handleShortcutItem(shortcut as! UIApplicationShortcutItem)
				launchedShortcutItem = nil
			}
		}
	}
	
	// MARK: - Force Touch Shortcut
	
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let handleShortcutItem = self.handleShortcutItem(shortcutItem)
		completionHandler(handleShortcutItem)
	}
	
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
	
	@available(iOS 9.0, *)
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
		guard let shortcutType = shortcutItem.type as String? else { return false }

		func handleShortCutForMenuIndex(_ index: Int) {
			var vc: UIViewController!
			if index == -1 {
				vc = profileVC
			} else {
				vc = sidebarVC.elements[index].viewController
			}
			revealVC.setFrontViewPosition(.left, animated: false)
			navigationController.setViewControllers([vc], animated: false)
			sidebarVC.preselectedIndex = index
		}
		
		switch (shortcutType) {
		case ShortcutIdentifier.Post.type:
			//Bring up Search for Post Song of the day
			handleShortCutForMenuIndex(0)
			feedVC.pretappedPlusButton = true
		case ShortcutIdentifier.PeopleSearch.type:
			//Bring up People Search Screen
			handleShortCutForMenuIndex(1)
		case ShortcutIdentifier.Liked.type:
			//Bring up Liked View
			handleShortCutForMenuIndex(2)
		case ShortcutIdentifier.Profile.type:
			//Bring up Profile Screen (of current user)
			profileVC.user = User.currentUser
			handleShortCutForMenuIndex(-1)
		default:
			return false
		}
		return true
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
