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
	
	/*
	TODO: Handle Spotify Access Token Expiration
	
	Currently, the app gets access tokens that only last for one hour, and once 
	the token expires, the app crashes upon launch. For now, users will have to login 
	every time the access token expires. We need to find a way to refresh the tokens
	before they expire. The Spotify iOS SDK requires developers to run their own token 
	exchange service to get refresh/swap tokens. This requires some backend changes.
	*/
	
	func spotifyIsAvailable(completion: Bool -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
                getSpotifyUser(session)
				completion(true)
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
    
	func saveSpotifyTrack(track: Post, completionHandler: (success: Bool) -> Void) {
        let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
        
        SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { (error: NSError!, data: AnyObject!) -> Void in
            if error != nil {
				completionHandler(success: false)
            } else {
                SPTYourMusic.saveTracks([data], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken, callback: { (error, result) -> Void in
                    if error != nil {
						completionHandler(success: false)
                    } else {
						completionHandler(success: true)
                    }
                })
            }
            
        }
    }
	
	func removeSavedSpotifyTrack(track: Post, completionHandler: (success: Bool) -> Void) {
		let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { (error: NSError!, data: AnyObject!) -> Void in
			if error != nil {
				completionHandler(success: false)
			} else {
				SPTYourMusic.removeTracksFromSaved([data], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken, callback: { (error, result) -> Void in
					if error != nil {
						completionHandler(success: false)
					} else {
						completionHandler(success: true)
					}
				})
			}
			
		}
	}
	
	func getPlaylists(completion:(playlists: [SPTPartialPlaylist]?, error: NSError?) -> Void) {
		SPTPlaylistList.playlistsForUserWithSession(SPTAuth.defaultInstance().session, callback: { (error: NSError!, data: AnyObject!) -> Void in
			if error != nil {
				completion(playlists: nil, error: error)
			} else {
				if let playlistData = data {
					let playlistList = playlistData as? SPTPlaylistList
					let playlists = (playlistList?.items as? [SPTPartialPlaylist])!
					completion(playlists: playlists, error: nil)
				} else {
					completion(playlists: nil, error: NSError(domain: "Parsing error", code: 404, userInfo: nil))
				}
			}
		})
	}
	
	func addTrackToPlaylist(playlist: SPTPartialPlaylist, track: Post, completionHandler: (success: Bool) -> Void) {
		let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { (error: NSError!, trackData: AnyObject!) -> Void in
			if error != nil {
				completionHandler(success: false)
			} else {
				SPTPlaylistSnapshot.playlistWithURI(playlist.uri, session: SPTAuth.defaultInstance().session) { (error: NSError!, playlistData: AnyObject!) -> Void in
					if error != nil {
						completionHandler(success: false)
					} else {
						let selectedPlaylist = playlistData as! SPTPlaylistSnapshot
						
						selectedPlaylist.addTracksToPlaylist([trackData], withSession: SPTAuth.defaultInstance().session, callback: { (error) -> Void in
							if error != nil {
								completionHandler(success: false)
							} else {
								completionHandler(success: true)
							}
						})
					}
				}
			}
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