//
//  SpotifyController.swift
//  Tempo
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
				completion(true)
			}
		} else {
			completion(false)
		}
	}
	
	func setSpotifyUser(accessToken: String) {
		do {
			let currentUserRequest = try SPTUser.createRequestForCurrentUserWithAccessToken(accessToken)
			let data: NSData?
			var error: NSError? = nil
			do {
				data = try NSURLConnection.sendSynchronousRequest(currentUserRequest, returningResponse: nil)
			} catch let error as NSError {
				print(error)
				data = nil
			}
			guard let unwrappedData = data else { return }
			let jsonDict = JSON(data: unwrappedData, options: NSJSONReadingOptions(rawValue: 0), error: &error)
			User.currentUser.currentSpotifyUser = CurrentSpotifyUser(json: jsonDict)
		} catch let error as NSError {
			print(error)
		}
	}
	
	func loginToSpotify(completionHandler: (success: Bool) -> Void) {
		API.sharedAPI.getSpotifyAccessToken { (success, accessToken, expiresAt) -> Void in
			if success {
				let expirationDate = NSDate(timeIntervalSince1970: expiresAt)
				let spotifyUsername = User.currentUser.currentSpotifyUser?.username
				SPTAuth.defaultInstance().session = SPTSession(userName: spotifyUsername, accessToken: accessToken, expirationDate: expirationDate)
				self.setSpotifyUser(accessToken)
				completionHandler(success: true)
			} else {
				if let spotifyLoginUrl = NSURL(string: accessToken) {
					UIApplication.sharedApplication().openURL(spotifyLoginUrl)
				} else {
					completionHandler(success: false)
				}
			}
		}
	}
	
	func openSpotifyURL() {
		let spotifyUserURL = User.currentUser.currentSpotifyUser!.spotifyUserURL
		UIApplication.sharedApplication().openURL(spotifyUserURL)
	}
	
	func saveSpotifyTrack(track: Post, completionHandler: (success: Bool) -> Void) {
		let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, data in
			if error != nil {
				print(error)
				completionHandler(success: false)
			} else {
				SPTYourMusic.saveTracks([data], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken) { error, result in
					if error != nil {
						completionHandler(success: false)
					} else {
						User.currentUser.currentSpotifyUser?.savedTracks[track.song.spotifyID] = true
						NSUserDefaults.standardUserDefaults().setValue(User.currentUser.currentSpotifyUser?.savedTracks, forKey: "savedTracks")
						completionHandler(success: true)
					}
				}
			}
			
		}
	}
	
	func removeSavedSpotifyTrack(track: Post, completionHandler: (success: Bool) -> Void) {
		let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, data in
			if error != nil {
				completionHandler(success: false)
			} else {
				SPTYourMusic.removeTracksFromSaved([data], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken) { error, result in
					if error != nil {
						completionHandler(success: false)
					} else {
						User.currentUser.currentSpotifyUser?.savedTracks[track.song.spotifyID] = nil
						NSUserDefaults.standardUserDefaults().setValue(User.currentUser.currentSpotifyUser?.savedTracks, forKey: "savedTracks")
						completionHandler(success: true)
					}
				}
			}
			
		}
	}
	
	func getPlaylists(completion:(playlists: [SPTPartialPlaylist]?, error: NSError?) -> Void) {
		SPTPlaylistList.playlistsForUserWithSession(SPTAuth.defaultInstance().session) { error, data in
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
		}
	}
	
	func addTrackToPlaylist(playlist: SPTPartialPlaylist, track: Post, completionHandler: (success: Bool) -> Void) {
		let spotifyTrackURI = NSURL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.trackWithURI(spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, trackData in
			if error != nil {
				completionHandler(success: false)
			} else {
				SPTPlaylistSnapshot.playlistWithURI(playlist.uri, session: SPTAuth.defaultInstance().session) { error, playlistData in
					if error != nil {
						completionHandler(success: false)
					} else {
						let selectedPlaylist = playlistData as! SPTPlaylistSnapshot
						
						selectedPlaylist.addTracksToPlaylist([trackData], withSession: SPTAuth.defaultInstance().session) { error in
							if error != nil {
								completionHandler(success: false)
							} else {
								completionHandler(success: true)
							}
						}
					}
				}
			}
		}
	}
	
	func closeCurrentSpotifySession() {
		SPTAuth.defaultInstance().session = nil
	}
	
}