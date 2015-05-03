//
//  Tools.swift
//  test
//
//  Created by Dennis Fedorko on 4/22/15.
//  Copyright (c) 2015 Dennis F. All rights reserved.
//

import UIKit

class Tools: UIView, UIActionSheetDelegate, FBTweakViewControllerDelegate {
    
    //let tweakMethods = Tweaks()
    var screenCapture:ADScreenCapture!
    var popup:UIActionSheet!
    var rootViewController:UIViewController!
    var fbTweaks:FBTweakViewController!
    var displayingTweaks = false
    var keyboardIsShowing = false
    
    
    init(rootViewController:UIViewController) {
        super.init(frame: rootViewController.view.frame)
        
        self.rootViewController = rootViewController
        self.userInteractionEnabled = false
        
        let gestureRecognizer = UISwipeGestureRecognizer()
        gestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        gestureRecognizer.numberOfTouchesRequired = 3
        screenCapture = ADScreenCapture(rootViewController: rootViewController, frame: rootViewController.view.frame, gestureRecognizer: gestureRecognizer)
        rootViewController.view.addSubview(screenCapture)
        rootViewController.view.addSubview(self)
        
        popup = UIActionSheet(title: "App Dev Tools", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Submit Screenshot", "Submit Message", "Tweaks")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "assignFirstResponder", name:"AssignToolsAsFirstResponder", object: nil)
        self.becomeFirstResponder()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("assignFirstResponder"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardShown"), name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDismissed"), name:UIKeyboardWillHideNotification , object: nil)
//        if ( self ) {
//            NSNotificationCenter		*center = [NSNotificationCenter defaultCenter];
//            [center addObserver:self selector:@selector(noticeShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
//            [center addObserver:self selector:@selector(noticeHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
//        }

    }
    
    func keyboardShown() {
        keyboardIsShowing = true
    }
    
    func keyboardDismissed() {
        keyboardIsShowing = false
    }
    
    func assignFirstResponder() {
        if(!keyboardIsShowing) {
            self.becomeFirstResponder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            popup.showInView(self.rootViewController.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == popup {
            switch buttonIndex {
//            case 1:
//                print("Submit Video")
//                if(!screenCapture.isRecording) {
//                    screenCapture.didStartRecording()
//                }
//                break
            case 1:
                print("Submit Screenshot")
                if(!screenCapture.isRecording) {
                    screenCapture.takeOneScreenshot()
                }
                break
            case 2:
                print("Submit Message")
                if(!screenCapture.isRecording) {
                    let vc = SubmitBugViewController()
                    self.screenCapture.viewController.presentViewController(vc, animated: true, completion: nil)
                }
                break
            case 3:
                print("Tweaks")
                if(!displayingTweaks) {
                    fbTweaks = FBTweakViewController(store: FBTweakStore.sharedInstance())
                    fbTweaks.tweaksDelegate = self
                    self.rootViewController.presentViewController(fbTweaks, animated: true, completion: { () -> Void in
                        self.displayingTweaks = true
                    })
                }
                break
                
            default:
                break
            }
            
        }
    }
    
    func tweakViewControllerPressedDone(tweakViewController: FBTweakViewController!) {
        tweakViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.assignFirstResponder()
            self.displayingTweaks = false
        })
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
   
}
