//
//  AppDelegate.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 3/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

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
	let suggestionsVC = FollowSuggestionTableViewController()
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
		
		if FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded {
			FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: false) { session, state, error in
				self.sessionStateChanged(session, state: state, error: error)
			}
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
		if !FBSession.activeSession().isOpen {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			window!.rootViewController = signInVC
		} else {
			//			if let shortcut = launchedShortcutItem as?
			if resetFirstVC {
				navigationController.setViewControllers([firstViewController], animated: false)
			}
			revealVC.setFrontViewController(navigationController, animated: false)
			revealVC.setRearViewController(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "Feed")),
				SideBarElement(title: "People", viewController: usersVC, image: UIImage(named: "People")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "Heart-Menu")),
				SideBarElement(title: "Spotify", viewController: spotifyVC, image: UIImage(named: "Spotify")),
				SideBarElement(title: "Suggestions", viewController: suggestionsVC, image: UIImage(named: "People")),
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
			}
		} else {
			firstViewController = feedVC
		}
		
	}
	
	// Facebook Session
	func sessionStateChanged(session : FBSession, state : FBSessionState, error : NSError?)
	{
		if error != nil {
			FBSession.activeSession().closeAndClearTokenInformation()
		} else {
			if state == FBSessionState.Open {
				let userRequest = FBRequest.requestForMe()
				
				userRequest.startWithCompletionHandler { connection, result, error in
					if error == nil {
						let fbid = result["id"] as! String
						API.sharedAPI.fbIdIsValid(fbid) { newUser in
							if newUser {
								let usernameVC = UsernameViewController(nibName: "UsernameViewController", bundle: nil)
								usernameVC.name = result["name"] as! String
								usernameVC.fbID = result["id"] as! String
								let navController = UINavigationController(rootViewController: usernameVC)
								self.window!.rootViewController = navController
							} else {
								API.sharedAPI.getCurrentUser("") { _ in
									let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
									appDelegate.toggleRootVC()
								}
							}
						}
					}
				}
			}
		}
		
		// Error Messages
		if state == .Closed || state == .ClosedLoginFailed {
			print("Session Closed")
		}
		if FBErrorUtility.shouldNotifyUserForError(error) == true {
			print("Error")
		} else {
			if FBErrorUtility.errorCategoryForError(error) == .UserCancelled {
				print("Login Cancelled")
			}
			else if FBErrorUtility.errorCategoryForError(error) == .AuthenticationReopenSession {
				print("Invalid Session")
			}
		}
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		let wasHandled = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
		if wasHandled {
			return true
		}
		
		if SPTAuth.defaultInstance().canHandleURL(url) {
			SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { [weak self] error, session in
				if error != nil {
					print("*** Auth error: \(error)")
				} else {
					self?.spotifyVC.updateSpotifyState()
				}
				})
			
			return true
		}
		
		return wasHandled
	}
	
	// MARK: - SWRevealDelegate
	
	func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
		UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
		if position == .Left {
			revealController.frontViewController.view.userInteractionEnabled = true
			revealController.frontViewController.revealViewController().tapGestureRecognizer()
		} else {
			revealController.frontViewController.view.userInteractionEnabled = false
		}
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		if #available(iOS 9.0, *) {
			guard let shortcut = launchedShortcutItem else { return }
			
			handleShortcutItem(shortcut as! UIApplicationShortcutItem)
			
			launchedShortcutItem = nil
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
			if vc == revealVC.frontViewController {
				revealVC.setFrontViewPosition(.Left, animated: false)
			}
			navigationController.setViewControllers([vc], animated: false)
			sidebarVC.preselectedIndex = index
		}
		
		switch (shortcutType) {
		case ShortcutIdentifier.Post.type:
			//Bring up Search for Post Song of the day
			handleShortCutForMenuIndex(0)
			feedVC.loadViewIfNeeded()
			feedVC.plusButtonTapped()
			break
		case ShortcutIdentifier.PeopleSearch.type:
			//Bring up People Search Screen
			handleShortCutForMenuIndex(1)
			break
		case ShortcutIdentifier.Liked.type:
			//Bring up Liked View
			handleShortCutForMenuIndex(2)
			break
		case ShortcutIdentifier.Profile.type:
			//Bring up Profile Screen (of current user)
			profileVC.user = User.currentUser
			handleShortCutForMenuIndex(-1)
			break
		default:
			return false
		}
		return true
	}
}