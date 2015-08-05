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
    
    var sidebarVC: SideBarViewController?
	var revealVC: SWRevealViewController?
	var feedNavVC: UINavigationController?
    var peopleNavVC: UINavigationController?
    var likedNavVC: UINavigationController?
	lazy var mainNavigationController = UINavigationController()
    
    // Toggle rootViewController
    func toggleRootVC() {
        if (!FBSession.activeSession().isOpen) {
            let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
            self.window!.rootViewController = signInVC
        } else {
            if (feedNavVC == nil) {
                let feedVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
                feedNavVC = UINavigationController(rootViewController: feedVC)
            }
            if (peopleNavVC == nil) {
                let peopleVC = PeopleSearchViewController()
                peopleNavVC = UINavigationController(rootViewController: peopleVC)
            }
            if (likedNavVC == nil) {
                let likedVC = LikedTableViewController(nibName: "LikedTableViewController", bundle: nil)
                likedNavVC = UINavigationController(rootViewController: likedVC)
            }
            
            if (sidebarVC == nil) {
                sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
                sidebarVC!.elements = [
                    SideBarElement(title: "Feed", viewController: feedNavVC, image: UIImage(named: "Feed-Icon")),
                    SideBarElement(title: "People", viewController: peopleNavVC, image: UIImage(named: "People-Icon")),
                    SideBarElement(title: "Liked", viewController: likedNavVC, image: UIImage(named: "Liked-Icon")),
                    SideBarElement(title: "Spotify", viewController: feedNavVC, image: UIImage(named: "Spotify-Icon"))
                ]
                sidebarVC!.selectionHandler = {
                    [weak self]
                    (viewController) in
                    if let viewController = viewController {
                        if let front = self?.revealVC?.frontViewController {
                            if viewController == front {
                                self?.revealVC?.setFrontViewPosition(.Left, animated: true)
                                return
                            }
                        }
                        
                        self?.revealVC?.setFrontViewController(viewController, animated: true)
                        self?.revealVC?.setFrontViewPosition(.Left, animated: true)
                    }
                }
            }
            
            if (revealVC == nil) {
                revealVC = SWRevealViewController(rearViewController: sidebarVC, frontViewController: feedNavVC)
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
                println("Session Opened")
                API.sharedAPI.getCurrentUser { _ in }
            }
        }
        
        // Error Messages
        if (state == FBSessionState.Closed || state == FBSessionState.ClosedLoginFailed) {
            println("Session Closed")
        }
        if (FBErrorUtility.shouldNotifyUserForError(error) == true) {
            println("Error")
        } else {
            if (FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.UserCancelled) {
                println("Login Cancelled")
            }
            else if (FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.AuthenticationReopenSession) {
                println("Invalid Session")
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        return wasHandled
    }
}