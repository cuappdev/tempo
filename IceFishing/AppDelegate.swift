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
    
    // Toggle rootViewController
    func toggleRootVC() {
        let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
        let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
        
        if (!FBSession.activeSession().isOpen) {
            self.window!.rootViewController = signInVC
        } else {
            let navController = UINavigationController(rootViewController: FeedViewController(nibName: "FeedViewController", bundle: nil))
            let revealController = SWRevealViewController(rearViewController: sidebarVC, frontViewController: navController)
            self.window!.rootViewController = revealController
            let gestureRecognizer = UISwipeGestureRecognizer()
            gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
            gestureRecognizer.numberOfTouchesRequired = 3
            let screenCapture = ADScreenCapture(navigationController: revealController, frame: revealController.view.frame, gestureRecognizer: gestureRecognizer)
            revealController.view.addSubview(screenCapture)
        }
    }
    
    // Facebook Session
    func sessionStateChanged(session : FBSession, state : FBSessionState, error : NSError?)
    {
        if (error != nil) {
            FBSession.activeSession().closeAndClearTokenInformation()
        } else {
            if (state == FBSessionState.Open) {
                println("Session Opened")
                // Request FB user info
                API.sharedAPI.getCurrentUser { _ in }
//                var userRequest : FBRequest = FBRequest.requestForMe()
//                userRequest.startWithCompletionHandler{(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
//                    
//                    if (error == nil) {
//                        let userName = result["name"]
//                        let userID = result["id"]
//                        let userEmail = result["email"]
//                        println(userName)
//                        println(userID)
//                        println(userEmail)
//                        
//                    } else {
//                        println("Error")
//                    }
//                }
            }
            toggleRootVC()
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

