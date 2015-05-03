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
    var tools:Tools!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
    var feedNavVC: UINavigationController?
    var revealVC: SWRevealViewController?
    var likedViewController: LikedTableViewController?
    
    //    var categories: [String: UIViewController?] = ["Feed": nil, "People": nil, "Liked": nil, "Spotify": nil]
    //    var symbols: [String] = ["Gray-Feed-Icon", "People-Icon", "Liked-Icon", "Music-Icon"]

    
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
            
            if (likedViewController == nil) {
                likedViewController = LikedTableViewController(nibName: "LikedTableViewController", bundle: nil)
            }
            
            if (sidebarVC == nil) {
                sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
                sidebarVC?.elements = [
                    SideBarElement(title: "Feed", viewController: feedNavVC, image: UIImage(named: "Feed-Icon")),
                    SideBarElement(title: "People", viewController: feedNavVC, image: UIImage(named: "People-Icon")),
                    SideBarElement(title: "Liked", viewController: likedViewController, image: UIImage(named: "Liked-Icon")),
                    SideBarElement(title: "Spotify", viewController: feedNavVC, image: UIImage(named: "Spotify-Icon"))
                ]
                sidebarVC?.selectionHandler = {
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
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

