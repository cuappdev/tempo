//
//  SpotifyController.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/16/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

public func spotifyAvailable() -> Bool {
	var spotifyAvailable = false
	
	SpotifyController.sharedController.spotifyIsAvailable { (success: Bool) in
		spotifyAvailable = success
	}
	
	return spotifyAvailable
}

class SpotifyController {
	
	let spotifyPlaylistURIKey = "SpotifyPlaylistURIKey"
	static let sharedController: SpotifyController = SpotifyController()
	var isSpotifyAvailable: Bool = false
	var authViewController: UIViewController? = nil
	
	func spotifyIsAvailable(_ completion: (Bool) -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				completion(true)
			}
		} else {
			completion(false)
		}
	}
	
	func setSpotifyUser(_ accessToken: String, completion: ((_ success: Bool) -> ())?) {
		do {
			let currentUserRequest = try SPTUser.createRequestForCurrentUser(withAccessToken: accessToken)			
			let task = URLSession.shared.dataTask(with: currentUserRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
				guard let unwrappedData = data, error == nil else { return }
				let jsonDict = JSON(data: unwrappedData)
				User.currentUser.currentSpotifyUser = CurrentSpotifyUser(json: jsonDict)
				self.isSpotifyAvailable = true
				completion?(true)
			})
			
			task.resume()
			
		} catch let error as NSError {
			isSpotifyAvailable = false
			print(error)
		}
	}
	
	func loginToSpotify(vc: UIViewController, _ completionHandler: @escaping (_ success: Bool) -> Void) {
		API.sharedAPI.getSpotifyAccessToken { (success, accessToken, expiresAt) -> Void in
			if success {
				let expirationDate = Date(timeIntervalSince1970: expiresAt)
				let spotifyUsername = User.currentUser.currentSpotifyUser?.username
				SPTAuth.defaultInstance().session = SPTSession(userName: spotifyUsername, accessToken: accessToken, expirationDate: expirationDate)
				self.setSpotifyUser(accessToken, completion: completionHandler)
			} else {
				// Display Safari VC Login
				let spotifyLoginURL = SPTAuth.defaultInstance().loginURL
				self.authViewController = SFSafariViewController(url: spotifyLoginURL!)
				
//				vc.present(self.authViewController!, animated: true, completion: {
//					API.sharedAPI.postSpotifyAccessToken(accessToken: SPTAuth.defaultInstance().session.accessToken)
//				})
				vc.present(self.authViewController!, animated: true, completion: nil)
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
					} else if let currentSpotifyUser = User.currentUser.currentSpotifyUser {
						currentSpotifyUser.savedTracks[track.song.spotifyID] = true as AnyObject?
						UserDefaults.standard.setValue(User.currentUser.currentSpotifyUser?.savedTracks, forKey: currentSpotifyUser.savedTracksKey)
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
		isSpotifyAvailable = false
	}
	
}
