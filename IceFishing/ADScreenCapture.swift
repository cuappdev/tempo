//
//  ADScreenCapture.swift
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Dennis F. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ADScreenCapture: UIView {
    
    var movieMaker:CEMovieMaker!
    var screenshotImages:[UIImage] = []
    var viewController:UIViewController!
    var recordingIndicator:UIView!
    var recordingURL:NSURL!
    var screenResolution:CGSize!
    
    init(navigationController:UIViewController, frame:CGRect, gestureRecognizer:UIGestureRecognizer)
    {
        super.init(frame:frame)
        self.viewController = navigationController
        self.userInteractionEnabled = false
        
        self.recordingIndicator = UIView(frame: CGRectMake(frame.width - 30, frame.height - 30, 20, 20))
        self.recordingIndicator.backgroundColor = UIColor.redColor()
        self.recordingIndicator.layer.cornerRadius = 10
        
        gestureRecognizer.addTarget(self, action: Selector("didStartRecording"))
        self.viewController.view.addGestureRecognizer(gestureRecognizer)
        
        let screenBounds = UIScreen.mainScreen().bounds
        let screenScale = UIScreen.mainScreen().scale
        screenResolution = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale)
    
    }

    init(frame: CGRect, viewController:UIViewController) {
        super.init(frame: frame)
        
        self.viewController = viewController
        
        self.userInteractionEnabled = false
        
        self.recordingIndicator = UIView(frame: CGRectMake(frame.width - 30, frame.height - 30, 20, 20))
        self.recordingIndicator.backgroundColor = UIColor.redColor()
        self.recordingIndicator.layer.cornerRadius = 10
        
        let gesture = UISwipeGestureRecognizer(target: self, action: Selector("didStartRecording"))
        gesture.numberOfTouchesRequired = 3
        gesture.direction = UISwipeGestureRecognizerDirection.Left
        self.viewController.view.addGestureRecognizer(gesture)
        
    }
    
    func didStartRecording() {
        println("did start recording")
        
        self.viewController.view.addSubview(recordingIndicator)
        
        let timeSpan:NSTimeInterval = 3.0
        screenshotImages = []
        let timer = NSTimer.scheduledTimerWithTimeInterval(1/15.0, target: self, selector: Selector("takeScreenShotOfView:"), userInfo: screenshotImages, repeats: true)
        
        let timerForTimer = NSTimer.scheduledTimerWithTimeInterval(timeSpan, target: self, selector: Selector("invalidateTimer:"), userInfo: timer, repeats: false)
        
        let runloop = NSRunLoop.currentRunLoop()
        runloop.addTimer(timer, forMode: NSRunLoopCommonModes)
        runloop.addTimer(timerForTimer, forMode: NSRunLoopCommonModes)

    }
    
    func invalidateTimer(t:NSTimer) {
        
        println("recording stopped")
        let timer = t.userInfo as NSTimer
        timer.invalidate()
        stitchImagesIntoVideo(screenshotImages)
        
    }
    
    func takeScreenShotOfView(timer:NSTimer){
        
        let layer = UIApplication.sharedApplication().keyWindow?.layer as CALayer!
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let screenshot:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        screenshotImages.append(screenshot)
        println(screenshotImages.count)
        
    }
    
    func stitchImagesIntoVideo(images:[UIImage]) {
        
        let settings = CEMovieMaker.videoSettingsWithCodec(AVVideoCodecH264, withWidth: screenResolution.width, andHeight: screenResolution.height)
        
        self.movieMaker = CEMovieMaker(settings: settings)
        self.movieMaker.createMovieFromImages(images, withCompletion: { (fileURL:NSURL!) -> Void in
            self.recordingIndicator.removeFromSuperview()
            self.recordingURL = fileURL
            self.showBugSubmitForm(fileURL)
        })
        
    }
    
    func showBugSubmitForm(fileURL:NSURL) {
        
        let vc = SubmitBugViewController()
        vc.recordingURL = fileURL
        self.viewController.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func viewMovieAtURL(fileURL:NSURL) {
        let playerController = MPMoviePlayerViewController(contentURL: fileURL)
        playerController.view.frame = viewController.view.bounds
        viewController.presentMoviePlayerViewControllerAnimated(playerController)
        viewController.view.addSubview(playerController.view)
        playerController.moviePlayer.prepareToPlay()
        playerController.moviePlayer.play()
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
