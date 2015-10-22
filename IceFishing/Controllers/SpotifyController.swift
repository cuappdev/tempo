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
    
    func saveSpotifyTrack(track: Post) {
        let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)
        
        do {
            let currentTrackRequest = try SPTTrack.createRequestForTrack(spotifyTrackURI, withAccessToken: SPTAuth.defaultInstance().session.accessToken, market: nil)
            let data = try NSURLConnection.sendSynchronousRequest(currentTrackRequest, returningResponse: nil)
            let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            let track = try SPTTrack.tracksFromDecodedJSON(json)
            SPTYourMusic.saveTracks(track, forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken, callback: { (error, result) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print(result)
                }
            })
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func createSpotifyPlaylist() {
        SPTPlaylistList.createPlaylistWithName("IceFishing", publicFlag: false, session: SPTAuth.defaultInstance().session) { error, snapshot in
            if error != nil {
                print(error)
            } else {
                
            }
        }
    }
    
    func closeCurrentSpotifySession() {
        SPTAuth.defaultInstance().session = nil
    }
}