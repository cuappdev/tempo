//
//  SpotifyController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/16/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

class SpotifyController {
	
	static let sharedController: SpotifyController = SpotifyController()
	
	func isSpotifySignedIn(completion: Bool -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				completion(true)
			} else {
				SPTAuth.defaultInstance().renewSession(session, callback: { (error, _) -> Void in
					if error != nil {
						completion(false)
					} else {
						completion(true)
					}
				})
			}
		} else {
			completion(false)
		}
	}
}