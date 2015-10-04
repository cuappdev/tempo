//
//  SpotifyController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/16/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON

class SpotifyController {
	
	let spotifyPlaylistURIKey = "SpotifyPlaylistURIKey"
	static let sharedController: SpotifyController = SpotifyController()
	
	func spotifyIsAvailable(completion: Bool -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
                getSpotifyUser(session)
				completion(true)
			} else {
				SPTAuth.defaultInstance().renewSession(session) { error, _ in
                    self.getSpotifyUser(session)
					completion(error == nil)
				}
			}
		} else {
			completion(false)
		}
	}
    
    func getSpotifyUser(session: SPTSession) {
        do {
            let currentUserRequest = try SPTUser.createRequestForCurrentUserWithAccessToken(session.accessToken)
            let data: NSData?
            var error: NSError? = nil
            do {
                data = try NSURLConnection.sendSynchronousRequest(currentUserRequest, returningResponse: nil)
            } catch let error as NSError {
                print(error)
                data = nil
            }
            let jsonDict = JSON(data: data!, options: NSJSONReadingOptions(rawValue: 0), error: &error)
            User.currentUser.currentSpotifyUser = CurrentSpotifyUser(json: jsonDict)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func openSpotifyURL() {
        let spotifyUserURL = User.currentUser.currentSpotifyUser!.spotifyUserURL
        UIApplication.sharedApplication().openURL(spotifyUserURL)
    }
    
    func closeCurrentSpotifySession() {
        SPTAuth.defaultInstance().session = nil
    }
}