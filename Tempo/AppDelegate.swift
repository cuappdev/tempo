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

extension NSURL {
	func getQueryItemValueForKey(key: String) -> AnyObject? {
		guard let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else { return nil }
		guard let queryItems = components.queryItems else { return nil }
		
		return queryItems.filter { $0.name == key }.first?.value
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SWRevealViewControllerDelegate {
	
	var window: UIWindow?
	var tools: Tools!
	let revealVC = SWRevealViewController()
	let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
	let feedVC = FeedViewController()
	let searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
	let usersVC = UsersViewController()
	let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
	let likedVC = LikedTableViewController()
	let spotifyVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
	let aboutVC = AboutViewController(nibName: "AboutViewController", bundle: nil)
	let navigationController = PlayerNavigationController()
	
	//slack info
	let slackChannel = "C04C10672"
	let slackToken = "xoxp-2342414247-2693337898-4405497914-7cb1a7"
	let slackUsername = "Bug Report Bot"
	
	//tools
	let toolsEnabled = true
	
	// Saved shortcut item used as a result of an app launch, used later when app is activated.
	var launchedShortcutItem: AnyObject?

	var firstViewController: UIViewController!
	var resetFirstVC = true
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		let URLCache = NSURLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		NSURLCache.setSharedURLCache(URLCache)
		
		// Set up navigation bar divider
		let navigationBar = navigationController.navigationBar
		let navigationSeparator = UIView(frame: CGRectMake(0, navigationBar.frame.size.height - 0.5, navigationBar.frame.size.width, 0.5))
		navigationSeparator.backgroundColor = UIColor.tempoDarkRed
		navigationSeparator.opaque = true
		navigationController.navigationBar.addSubview(navigationSeparator)
		
		StyleController.applyStyles()
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		SPTAuth.defaultInstance().clientID = "0bc3fa31e7b141ed818f37b6e29a9e85"
		SPTAuth.defaultInstance().redirectURL = NSURL(string: "icefishing-login://callback")
		SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifyUserDefaultsKey"
		SPTAuth.defaultInstance().requestedScopes = [
			SPTAuthPlaylistReadPrivateScope,
			SPTAuthPlaylistModifyPublicScope,
			SPTAuthPlaylistModifyPrivateScope,
			SPTAuthUserLibraryReadScope,
			SPTAuthUserLibraryModifyScope
		]
		
		if SPTAuth.defaultInstance().session != nil && SPTAuth.defaultInstance().session.isValid() {
			SpotifyController.sharedController.setSpotifyUser(SPTAuth.defaultInstance().session.accessToken)
			User.currentUser.currentSpotifyUser?.savedTracks = NSUserDefaults.standardUserDefaults().dictionaryForKey("savedTracks") ?? [:]
		}

		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window!.backgroundColor = UIColor.tempoLightGray
		window!.makeKeyAndVisible()
		
		FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		if FBSDKAccessToken.currentAccessToken() != nil {
			fbSessionStateChanged(nil)
		}
		
		// Check if it's launched from Quick Action
		var shouldPerformAdditionalDelegateHandling = true
		if #available(iOS 9.0, *) {
			if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
				launchedShortcutItem = shortcutItem
				shouldPerformAdditionalDelegateHandling = false
				resetFirstVC = false
			}
		}
		
		setFirstVC()
		toggleRootVC()
		
		//declaration of tools remains active in background while app runs
		if toolsEnabled {
			tools = Tools(rootViewController: window!.rootViewController!, slackChannel: slackChannel, slackToken: slackToken, slackUsername: slackUsername)
		}
		
		return shouldPerformAdditionalDelegateHandling
	}
	
	func toggleRootVC() {
		if FBSDKAccessToken.currentAccessToken() == nil {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			window!.rootViewController = signInVC
		} else {
			if resetFirstVC {
				navigationController.setViewControllers([firstViewController], animated: false)
			}
			revealVC.setFrontViewController(navigationController, animated: false)
			revealVC.setRearViewController(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "feed-sidebar-icon")),
				SideBarElement(title: "People", viewController: usersVC, image: UIImage(named: "people-sidebar-icon")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "liked-sidebar-icon")),
				SideBarElement(title: "Spotify", viewController: spotifyVC, image: UIImage(named: "spotify-sidebar-icon")),
				SideBarElement(title: "About", viewController: aboutVC, image: UIImage(named: "about-sidebar-icon"))
			]
			sidebarVC.selectionHandler = { [weak self] viewController in
				if let viewController = viewController {
					if let front = self?.revealVC.frontViewController {
						if viewController == front {
							self?.revealVC.setFrontViewPosition(.Left, animated: true)
							return
						}
					}
					self?.navigationController.setViewControllers([viewController], animated: false)
					self?.revealVC.setFrontViewPosition(.Left, animated: true)
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
	
	func loginToFacebook() {
		let fbLoginManager = FBSDKLoginManager()
		fbLoginManager.logOut()
		fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: nil) { loginResult, error in
			if error != nil {
				print("Facebook login error: \(error)")
			} else if loginResult.isCancelled {
				print("FB Login Cancelled")
			} else {
				self.fbSessionStateChanged(error)
			}
		}
		Shared.imageCache.removeAll()
	}
	
	// Facebook Session
	func fbSessionStateChanged(error : NSError?) {
		guard error == nil else { FBSDKAccessToken.setCurrentAccessToken(nil); return }
		guard FBSDKAccessToken.currentAccessToken() != nil else { return }
		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
		
		userRequest.startWithCompletionHandler() { connection, result, error in
			guard error == nil else { print("Error getting Facebook user: \(error)"); return }
			let fbid = result["id"] as! String
			let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
			
			API.sharedAPI.fbAuthenticate(fbid, userToken: fbAccessToken) { success, newUser in
				guard success else { return }
				if newUser {
					let usernameVC = UsernameViewController(nibName: "UsernameViewController", bundle: nil)
					usernameVC.name = result["name"] as! String
					usernameVC.fbID = result["id"] as! String
					self.window!.rootViewController = UINavigationController(rootViewController: usernameVC)
				} else {
					API.sharedAPI.setCurrentUser(fbid, fbAccessToken: fbAccessToken) { success in
						guard success else { return }
						let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
						appDelegate.toggleRootVC()
						guard let vc = self.firstViewController as? ProfileViewController else { return }
						vc.user = User.currentUser
						vc.setupUserUI()
					}
				}
			}
		}
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		if url.absoluteString.containsString(SPTAuth.defaultInstance().redirectURL.absoluteString) {
			SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url) { [weak self] error, session in
				if error != nil {
					print("*** Auth error: \(error)")
				} else {
					let accessToken = url.getQueryItemValueForKey("access_token") as? String
					let unixExpirationDate = url.getQueryItemValueForKey("expires_at") as? String
					let expirationDate = NSDate(timeIntervalSince1970: Double(unixExpirationDate!)!)
					
					SpotifyController.sharedController.setSpotifyUser(accessToken!)
					SPTAuth.defaultInstance().session = SPTSession(userName: User.currentUser.currentSpotifyUser?.username, accessToken: accessToken, expirationDate: expirationDate)
					self?.spotifyVC.updateSpotifyState()
				}
			}
			
			return true
		}
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	// MARK: - SWRevealDelegate
	
	func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
		UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
		if position == .Left {
			revealController.frontViewController.view.userInteractionEnabled = true
			revealController.frontViewController.revealViewController().tapGestureRecognizer()
		} else {
			revealController.frontViewController.view.userInteractionEnabled = false
		}
		//Notify any hamburger menus that the menu is being toggled
		NSNotificationCenter.defaultCenter().postNotificationName(RevealControllerToggledNotificaiton, object: revealController)
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		FBSDKAppEvents.activateApp()
		
		if #available(iOS 9.0, *) {
			guard let shortcut = launchedShortcutItem else { return }

			if FBSDKAccessToken.currentAccessToken() != nil {
				handleShortcutItem(shortcut as! UIApplicationShortcutItem)
				launchedShortcutItem = nil
			}
		}
	}
	
	// MARK: - Force Touch Shortcut
	
	@available(iOS 9.0, *)
	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		let handleShortcutItem = self.handleShortcutItem(shortcutItem)
		completionHandler(handleShortcutItem)
	}
	
	enum ShortcutIdentifier: String {
		case Post
		case PeopleSearch
		case Liked
		case Profile
		
		init?(fullType: String) {
			guard let last = fullType.componentsSeparatedByString(".").last else {return nil}
			self.init(rawValue: last)
		}
		
		var type: String {
			return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
		}
	}
	
	@available(iOS 9.0, *)
	func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
		guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
		guard let shortcutType = shortcutItem.type as String? else { return false }

		func handleShortCutForMenuIndex(index: Int) {
			var vc: UIViewController!
			if index == -1 {
				vc = profileVC
			} else {
				vc = sidebarVC.elements[index].viewController
			}
			revealVC.setFrontViewPosition(.Left, animated: false)
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
}