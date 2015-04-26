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
        
        FBLoginView.self
        FBProfilePictureView.self
        
        // Check for a cached session whenever app is opened
        if FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded
        {
            
            // If there's one, just open the session silently, without showing the user the login UI
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: false, completionHandler: {
                (session, state, error) -> Void in
                self.sessionStateChanged(session, state: state, error: error)
            })
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        let sidebarVC = SideBarViewController(nibName: "SideBarViewController", bundle: nil)
        let signInVC = SignInViewController(nibName: "SignInViewController", bundle: nil)
        
        let viewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        
        let navController = UINavigationController(rootViewController: MainViewController())
        let revealController = SWRevealViewController(rearViewController: sidebarVC, frontViewController: navController)
        self.window!.rootViewController = revealController
        let gestureRecognizer = UISwipeGestureRecognizer()
        gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        gestureRecognizer.numberOfTouchesRequired = 3
        let screenCapture = ADScreenCapture(navigationController: revealController, frame: revealController.view.frame, gestureRecognizer: gestureRecognizer)
        revealController.view.addSubview(screenCapture)
        
        return true
    }
    
    // Facebook Session
    func sessionStateChanged(session : FBSession, state : FBSessionState, error : NSError?)
    {
        // If the session was opened successfully
        if state == FBSessionState.Open {
            println("Session Opened")
        }
        // If the session closed
        if state == FBSessionState.Closed {
            println("Session Closed")
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

