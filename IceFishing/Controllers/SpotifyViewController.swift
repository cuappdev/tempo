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
    @IBOutlet weak var nameLabel: UILabel!
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
		
		for button in [loginToSpotifyButton, goToSpotifyButton, logOutSpotifyButton] {
			button.backgroundColor = UIColor.iceDarkRed
			button.layer.cornerRadius = 5.0
			button.layer.masksToBounds = true
		}
		
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		SpotifyController.sharedController.spotifyIsAvailable { (success) -> Void in
			self.loggedInToSpotify(success)
			if success {
				let currentSpotifyUser = User.currentUser.currentSpotifyUser
				self.nameLabel.text = currentSpotifyUser!.name
				currentSpotifyUser!.loadImage {
					self.profilePicture.image = $0
				}
			}
		}
	}
    
    func loggedInToSpotify(loggedIn: Bool) {
        let elements = [profilePicture, nameLabel, createPlaylistSwitch, goToSpotifyButton, logOutSpotifyButton]
        loginToSpotifyButton.hidden = loggedIn
        for e in elements {
            e.hidden = !loggedIn
        }
    }
    
	@IBAction func loginToSpotify() {
		let loginURL = SPTAuth.defaultInstance().loginURL
		delay(0.1) { () -> () in
			UIApplication.sharedApplication().openURL(loginURL)
		}
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
