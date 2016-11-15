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
	
	func spotifyIsAvailable(_ completion: (Bool) -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				completion(true)
			}
		} else {
			completion(false)
		}
	}
	
	func setSpotifyUser(_ accessToken: String) {
		do {
			let currentUserRequest = try SPTUser.createRequestForCurrentUser(withAccessToken: accessToken)
			let data: Data?
			var error: NSError? = nil
			do {
				data = try NSURLConnection.sendSynchronousRequest(currentUserRequest, returning: nil)
			} catch let error as NSError {
				print(error)
				data = nil
			}
			guard let unwrappedData = data else { return }
			let jsonDict = JSON(data: unwrappedData, options: JSONSerialization.ReadingOptions(rawValue: 0), error: &error)
			User.currentUser.currentSpotifyUser = CurrentSpotifyUser(json: jsonDict)
		} catch let error as NSError {
			print(error)
		}
	}
	
	func loginToSpotify(_ completionHandler: @escaping (_ success: Bool) -> Void) {
		API.sharedAPI.getSpotifyAccessToken { (success, accessToken, expiresAt) -> Void in
			if success {
				let expirationDate = Date(timeIntervalSince1970: expiresAt)
				let spotifyUsername = User.currentUser.currentSpotifyUser?.username
				SPTAuth.defaultInstance().session = SPTSession(userName: spotifyUsername, accessToken: accessToken, expirationDate: expirationDate)
				self.setSpotifyUser(accessToken)
				completionHandler(true)
			} else {
				if let spotifyLoginUrl = URL(string: accessToken) {
					UIApplication.shared.openURL(spotifyLoginUrl)
				} else {
					completionHandler(false)
				}
			}
		}
	}
	
	func openSpotifyURL() {
		let spotifyUserURL = User.currentUser.currentSpotifyUser!.spotifyUserURL
		UIApplication.shared.openURL(spotifyUserURL as URL)
	}
	
	func saveSpotifyTrack(_ track: Post, completionHandler: @escaping (_ success: Bool) -> Void) {
		let spotifyTrackURI = URL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.track(withURI: spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, data in
			if error != nil {
				print(error as Any)
				completionHandler(false)
			} else {
				SPTYourMusic.saveTracks([data!], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken) { error, result in
					if error != nil {
						completionHandler(false)
					} else {
						User.currentUser.currentSpotifyUser?.savedTracks[track.song.spotifyID] = true as AnyObject?
						UserDefaults.standard.setValue(User.currentUser.currentSpotifyUser?.savedTracks, forKey: "savedTracks")
						completionHandler(true)
					}
				}
			}
			
		}
	}
	
	func removeSavedSpotifyTrack(_ track: Post, completionHandler: @escaping (_ success: Bool) -> Void) {
		let spotifyTrackURI = URL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.track(withURI: spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, data in
			if error != nil {
				completionHandler(false)
			} else {
				SPTYourMusic.removeTracks(fromSaved: [data!], forUserWithAccessToken: SPTAuth.defaultInstance().session.accessToken) { error, result in
					if error != nil {
						completionHandler(false)
					} else {
						User.currentUser.currentSpotifyUser?.savedTracks[track.song.spotifyID] = nil
						UserDefaults.standard.setValue(User.currentUser.currentSpotifyUser?.savedTracks, forKey: "savedTracks")
						completionHandler(true)
					}
				}
			}
			
		}
	}
	
	func getPlaylists(_ completion:@escaping (_ playlists: [SPTPartialPlaylist]?, _ error: NSError?) -> Void) {
		SPTPlaylistList.playlistsForUser(with: SPTAuth.defaultInstance().session) { error, data in
			if error != nil {
				completion(nil, error as NSError?)
			} else {
				if let playlistData = data {
					let playlistList = playlistData as? SPTPlaylistList
					let playlists = (playlistList?.items as? [SPTPartialPlaylist])!
					completion(playlists, nil)
				} else {
					completion(nil, NSError(domain: "Parsing error", code: 404, userInfo: nil))
				}
			}
		}
	}
	
	func addTrackToPlaylist(_ playlist: SPTPartialPlaylist, track: Post, completionHandler: @escaping (_ success: Bool) -> Void) {
		let spotifyTrackURI = URL(string: "spotify:track:" + track.song.spotifyID)!
		
		SPTTrack.track(withURI: spotifyTrackURI, session: SPTAuth.defaultInstance().session) { error, trackData in
			if error != nil {
				completionHandler(false)
			} else {
				SPTPlaylistSnapshot.playlist(withURI: playlist.uri, session: SPTAuth.defaultInstance().session) { error, playlistData in
					if error != nil {
						completionHandler(false)
					} else {
						let selectedPlaylist = playlistData as! SPTPlaylistSnapshot
						
						selectedPlaylist.addTracks(toPlaylist: [trackData!], with: SPTAuth.defaultInstance().session) { error in
							if error != nil {
								completionHandler(false)
							} else {
								completionHandler(true)
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
