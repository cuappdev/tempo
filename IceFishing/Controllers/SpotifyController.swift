//
//  SpotifyController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/16/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

class SpotifyController {
	
	let spotifyPlaylistURIKey = "SpotifyPlaylistURIKey"
	
	static let sharedController: SpotifyController = SpotifyController()
	
	func spotifyIsAvailable(completion: Bool -> Void) {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				completion(true)
			} else {
				SPTAuth.defaultInstance().renewSession(session) { error, _ in
					completion(error == nil)
				}
			}
		} else {
			completion(false)
		}
	}
	
	func createPlaylist() {
		SPTPlaylistList.createPlaylistWithName("IceFishing", publicFlag: false, session: SPTAuth.defaultInstance().session) { error, snapshot in
			if error != nil {
				print(error)
			} else {
				
			}
		}
	}
}