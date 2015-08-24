//
//  SpotifyViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/9/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SpotifyViewController: UIViewController {
	
	@IBOutlet var label: UILabel!
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		beginIceFishing()
		updateSpotifyState()
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		SpotifyController.sharedController.spotifyIsAvailable { [weak self] in
			self?.label.text = $0 ? "Session is valid" : "No valid Spotify session"
		}
	}
	
	@IBAction func loginToSpotify() {
		let loginURL = SPTAuth.defaultInstance().loginURL
		UIApplication.sharedApplication().openURL(loginURL)
	}
	
	@IBAction func createIceFishingPlaylist() {
		SpotifyController.sharedController.createPlaylist()
	}
}
