//
//  AppDelegate.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 3/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SWRevealViewController

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
	let navigationController = UINavigationController()
	
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
		// TODO: Figure out a way to get rid of this, since it's deprecated
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
		
		let URLCache = NSURLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		NSURLCache.setSharedURLCache(URLCache)
		
		StyleController.applyStyles()
		
		//		let appDomain = NSBundle.mainBundle().bundleIdentifier!;
		//		NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain);
		
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
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window!.backgroundColor = UIColor.iceLightGray
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
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "Feed")),
				SideBarElement(title: "People", viewController: usersVC, image: UIImage(named: "People")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "Heart-Menu")),
				SideBarElement(title: "Spotify", viewController: spotifyVC, image: UIImage(named: "Spotify"))
			]
			sidebarVC.selectionHandler = {
				[weak self]
				(viewController) in
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
				guard let shortcutType = shortcutItem.type as String? else { firstViewController = feedVC }
				switch (shortcutType) {
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
			} else {
				firstViewController = feedVC
			}
		} else {
			firstViewController = feedVC
		}
		
	}
	
	func loginToFacebook() {
		let fbLoginManager = FBSDKLoginManager.init()
		fbLoginManager.logOut()
		fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: nil, handler: { (loginResult, error) -> Void in
			if error != nil {
				print("Facebook login error: \(error)")
			} else if loginResult.isCancelled {
				print("FB Login Cancelled")
			} else {
				self.fbSessionStateChanged(error)
			}
		})
	}
	
	// Facebook Session
	func fbSessionStateChanged(error : NSError?)
	{
		if error != nil {
			FBSDKAccessToken.setCurrentAccessToken(nil)
		} else {
			if FBSDKAccessToken.currentAccessToken() != nil {
				let userRequest = FBSDKGraphRequest(graphPath: "me",
					parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
				
				userRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
					if error != nil {
						print("Error getting Facebook user: \(error)")
					} else {
						let fbid = result["id"] as! String
						let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
						
						API.sharedAPI.fbAuthenticate(fbid, userToken: fbAccessToken, completion: { (success) in
							if success {
								if User.currentUser.username.isEmpty { // New user
									let usernameVC = UsernameViewController(nibName: "UsernameViewController", bundle: nil)
									usernameVC.name = result["name"] as! String
									usernameVC.fbID = result["id"] as! String
									let navController = UINavigationController(rootViewController: usernameVC)
									self.window!.rootViewController = navController
								} else { // Old user
									API.sharedAPI.setCurrentUser(fbid, fbAccessToken: fbAccessToken, completion: { (success) in
										if success {
											let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
											appDelegate.toggleRootVC()
											if let vc = self.firstViewController as? ProfileViewController {
												vc.user = User.currentUser
												vc.setupUserUI()
											}
										}
									})
								}
							}
						})
					}
				})
			}
		}
	}
	
	
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		if url.absoluteString.containsString(SPTAuth.defaultInstance().redirectURL.absoluteString) {
			SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { [weak self] error, session in
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
			})
			
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