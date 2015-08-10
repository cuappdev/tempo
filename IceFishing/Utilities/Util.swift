//
//  Util.swift
//  IceFishing
//
//  Created by Austin Chan on 4/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

func loadImageAsync(url: NSURL, completion: (UIImage!, NSError!) -> ()) {
    let requestedURL = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 10.0)
	
	NSURLSession.sharedSession().dataTaskWithRequest(requestedURL, completionHandler: { (data, response, error) -> Void in
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			error != nil ? completion(nil, error) : completion(UIImage(data: data!), nil)
		})
	}).resume()
}

func transparentPNG(length: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(length, length), false, 0.0)
    let blank = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return blank
}
