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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SWRevealViewControllerDelegate {
	
	var window: UIWindow?
	var tools: Tools!
	let revealVC = SWRevealViewController()
	let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
	let feedVC = FeedViewController()
    let searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
	let likedVC = LikedTableViewController(nibName: "LikedTableViewController", bundle: nil)
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
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window!.backgroundColor = UIColor.iceLightGray
		self.window!.makeKeyAndVisible()
		
		FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		if FBSDKAccessToken.currentAccessToken() != nil {
			fbSessionStateChanged(nil)
		}
		
		toggleRootVC()
		
		//declaration of tools remains active in background while app runs
		if toolsEnabled {
			tools = Tools(rootViewController: self.window!.rootViewController!, slackChannel: slackChannel, slackToken: slackToken, slackUsername: slackUsername)
		}
		
		return true
	}
	
	func toggleRootVC() {
		if FBSDKAccessToken.currentAccessToken() == nil {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			self.window!.rootViewController = signInVC
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
			
			self.window!.rootViewController = revealVC
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
						API.sharedAPI.fbIdIsValid(fbid) { (newUser) -> Void in
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
				})
			}
		}
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
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
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		FBSDKAppEvents.activateApp()
	}
	
	// MARK: - SWRevealDelegate
	
	func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
		UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
	}
}