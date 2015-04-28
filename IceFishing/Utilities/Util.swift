//
//  Util.swift
//  IceFishing
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

let screenSize: CGRect = UIScreen.mainScreen().bounds

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func loadImageAsync(stringURL: NSString, completion: (UIImage!, NSError!) -> ()) {
    let url = NSURL(string: stringURL as String)
    let requestedURL = NSURLRequest(URL: url!)
    
    NSURLConnection.sendAsynchronousRequest(requestedURL, queue: NSOperationQueue.mainQueue()) {
        response, data, error in
        
        if error != nil {
            completion(nil, error)
        } else {
            completion(UIImage(data: data), nil)
        }
    }
}

func transparentPNG(length: Int) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGFloat(length), CGFloat(length)), false, 0.0)
    var blank = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return blank
}
