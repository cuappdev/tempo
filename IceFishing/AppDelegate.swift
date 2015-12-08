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
	let likedVC = LikedTableViewController()
	let spotifyVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
	let navigationController = UINavigationController()
	
	//slack info
	let slackChannel = "C04C10672"
	let slackToken = "xoxp-2342414247-2693337898-4405497914-7cb1a7"
	let slackUsername = "Bug Report Bot"
	
	//tools
	let toolsEnabled = true
	
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

		toggleRootVC()
		
		//declaration of tools remains active in background while app runs
		if toolsEnabled {
			tools = Tools(rootViewController: window!.rootViewController!, slackChannel: slackChannel, slackToken: slackToken, slackUsername: slackUsername)
		}
		
		return true
	}
	
	func toggleRootVC() {
		if !FBSession.activeSession().isOpen {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			window!.rootViewController = signInVC
		} else {
			navigationController.setViewControllers([feedVC], animated: false)
			revealVC.setFrontViewController(navigationController, animated: false)
			revealVC.setRearViewController(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "Feed")),
				SideBarElement(title: "People", viewController: searchVC, image: UIImage(named: "People")),
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
}