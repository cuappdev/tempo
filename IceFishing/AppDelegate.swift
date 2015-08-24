//
//  AppDelegate.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 3/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var tools: Tools!
	let revealVC = SWRevealViewController()
	let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
	let feedVC = FeedViewController()
	let peopleVC = PeopleSearchViewController()
	let likedVC = LikedTableViewController(nibName: "LikedTableViewController", bundle: nil)
	let spotifyVC = SpotifyViewController(nibName: "SpotifyViewController", bundle: nil)
	let navigationController = UINavigationController()
	
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
		SPTAuth.defaultInstance().requestedScopes = [SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope]
		SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifyUserDefaultsKey"
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window!.backgroundColor = UIColor.iceLightGray
		self.window!.makeKeyAndVisible()
		
		if FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded {
			FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: false, completionHandler: { session, state, error in
				self.sessionStateChanged(session, state: state, error: error)
			})
		}
		
		toggleRootVC()
		
		return true
	}
	
	func toggleRootVC() {
		if !FBSession.activeSession().isOpen {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			self.window!.rootViewController = signInVC
		} else {
			navigationController.setViewControllers([feedVC], animated: false)
			revealVC.setFrontViewController(navigationController, animated: false)
			revealVC.setRearViewController(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "Feed")),
				SideBarElement(title: "People", viewController: peopleVC, image: UIImage(named: "People")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "Heart")),
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
			
			self.window!.rootViewController = revealVC
		}
		tools = Tools(rootViewController: self.window!.rootViewController!)
	}
	
	// Facebook Session
	func sessionStateChanged(session : FBSession, state : FBSessionState, error : NSError?)
	{
		if error != nil {
			FBSession.activeSession().closeAndClearTokenInformation()
		} else {
			if state == FBSessionState.Open {
				print("Session Opened")
				API.sharedAPI.getCurrentUser { _ in }
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
}