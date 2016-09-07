//
//  NSURLSession+Shared.swift
//  Tempo
//
//  Created by Lucas Derraugh on 12/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import Foundation

extension NSURLSession {
	@nonobjc private static let sharedCachedSession: NSURLSession = {
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.requestCachePolicy = .ReturnCacheDataElseLoad
		return NSURLSession(configuration: config)
	}()
	
	class func dataTaskWithCachedRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
		let completionWithCaching: (NSData?, NSURLResponse?, NSError?) -> Void = { data, response, error in
			completionHandler(data, response, error)
			if let data = data, response = response {
				let cachedResponse = NSCachedURLResponse(response: response, data: data)
				NSURLCache.sharedURLCache().storeCachedResponse(cachedResponse, forRequest: request)
			}
		}
		return sharedCachedSession.dataTaskWithRequest(request, completionHandler: completionWithCaching)
	}
}