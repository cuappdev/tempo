//
//  NSURLSession+Shared.swift
//  Tempo
//
//  Created by Lucas Derraugh on 12/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import Foundation

extension URLSession {
	@nonobjc fileprivate static let sharedCachedSession: URLSession = {
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .returnCacheDataElseLoad
		return URLSession(configuration: config)
	}()
	
	class func dataTaskWithCachedRequest(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
		let completionWithCaching = { (data: Data?, response: URLResponse?, error: Error?) in
			completionHandler(data, response, error)
			if let data = data, let response = response {
				let cachedResponse = CachedURLResponse(response: response, data: data)
				URLCache.shared.storeCachedResponse(cachedResponse, for: request)
			}
		}
		
		return sharedCachedSession.dataTask(with: request, completionHandler: completionWithCaching)
	}
}
