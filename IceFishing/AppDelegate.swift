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
	lazy var revealVC = SWRevealViewController()
	lazy var sidebarVC: SideBarViewController = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
	lazy var feedVC: FeedViewController = FeedViewController(nibName: "FeedViewController", bundle: nil)
	lazy var peopleVC: PeopleSearchViewController = PeopleSearchViewController()
	lazy var likedVC: LikedTableViewController = LikedTableViewController(nibName: "LikedTableViewController", bundle: nil)
	lazy var mainNavigationController = UINavigationController()
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
		
		let URLCache = NSURLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
		NSURLCache.setSharedURLCache(URLCache)
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window!.backgroundColor = UIColor.whiteColor()
		self.window!.makeKeyAndVisible()
		
		// Check for a cached session whenever app is opened
		if (FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded) {
			// If there's one, open session without displaying Login UI
			FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: false, completionHandler: { (session, state, error) -> Void in
				self.sessionStateChanged(session, state: state, error: error)
			})
		}
		
		// Go to feed if open session, else sign in screen
		toggleRootVC()
		
		return true
	}
	
	// Toggle rootViewController
	func toggleRootVC() {
		if (!FBSession.activeSession().isOpen) {
			let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
			self.window!.rootViewController = signInVC
		} else {
			mainNavigationController.setViewControllers([feedVC], animated: false)
			revealVC.setFrontViewController(mainNavigationController, animated: false)
			revealVC.setRearViewController(sidebarVC, animated: false)
			sidebarVC.elements = [
				SideBarElement(title: "Feed", viewController: feedVC, image: UIImage(named: "Feed-Icon")),
				SideBarElement(title: "People", viewController: peopleVC, image: UIImage(named: "People-Icon")),
				SideBarElement(title: "Liked", viewController: likedVC, image: UIImage(named: "Liked-Icon")),
				SideBarElement(title: "Spotify", viewController: feedVC, image: UIImage(named: "Spotify-Icon"))
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
					self?.mainNavigationController.setViewControllers([viewController], animated: false)
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
		if (error != nil) {
			FBSession.activeSession().closeAndClearTokenInformation()
		} else {
			if (state == FBSessionState.Open) {
				print("Session Opened")
				API.sharedAPI.getCurrentUser { _ in }
			}
		}
		
		// Error Messages
		if (state == FBSessionState.Closed || state == FBSessionState.ClosedLoginFailed) {
			print("Session Closed")
		}
		if (FBErrorUtility.shouldNotifyUserForError(error) == true) {
			print("Error")
		} else {
			if (FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.UserCancelled) {
				print("Login Cancelled")
			}
			else if (FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.AuthenticationReopenSession) {
				print("Invalid Session")
			}
		}
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		let wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
		return wasHandled
	}
}