//
//  SpotifyViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/9/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SpotifyViewController: UIViewController {
	
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loginToSpotifyButton: UIButton!
    @IBOutlet weak var createPlaylistSwitch: UISwitch!
    @IBOutlet weak var goToSpotifyButton: UIButton!
    @IBOutlet weak var logOutSpotifyButton: UIButton!
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		title = "Spotify"
		addHamburgerMenu()
		addRevealGesture()
		updateSpotifyState()
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        createPlaylistSwitch.tintColor = UIColor.iceDarkRed
        createPlaylistSwitch.onTintColor = UIColor.iceDarkRed
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		SpotifyController.sharedController.spotifyIsAvailable { [weak self] in
            self!.loggedInToSpotify($0)
            if $0 {
                let currentSpotifyUser = User.currentUser.currentSpotifyUser
                self!.usernameLabel.text = "Logged in as \(currentSpotifyUser!.username)"
                currentSpotifyUser!.loadImage {
                    self?.profilePicture.image = $0
                }
            }
		}
	}
    
    func loggedInToSpotify(loggedIn: Bool) {
        let elements = [profilePicture, usernameLabel, createPlaylistSwitch, goToSpotifyButton, logOutSpotifyButton]
        loginToSpotifyButton.hidden = loggedIn
        for e in elements {
            e.hidden = !loggedIn
        }
    }
    
	@IBAction func loginToSpotify() {
        SPTAuth.defaultInstance().requestedScopes = [
            SPTAuthPlaylistReadPrivateScope,
            SPTAuthPlaylistModifyPublicScope,
            SPTAuthPlaylistModifyPrivateScope,
            SPTAuthUserLibraryReadScope,
            SPTAuthUserLibraryModifyScope
        ]

		let loginURL = SPTAuth.defaultInstance().loginURL
		UIApplication.sharedApplication().openURL(loginURL)
	}
    
    @IBAction func toggleCreatePlaylistSwitch(sender: UISwitch) {
        if sender.on {
            
        } else {
            
        }
    }
    
    @IBAction func goToSpotify(sender: UIButton) {
        SpotifyController.sharedController.openSpotifyURL()
    }
    
    @IBAction func logOutSpotify(sender: UIButton) {
        SpotifyController.sharedController.closeCurrentSpotifySession()
        updateSpotifyState()
    }
	
}
