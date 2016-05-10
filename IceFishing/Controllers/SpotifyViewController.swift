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
    @IBOutlet weak var loginText: UILabel!
	
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
        createPlaylistSwitch.tintColor = UIColor.tempoLightRed
        createPlaylistSwitch.onTintColor = UIColor.tempoLightRed
		
		for button in [loginToSpotifyButton, goToSpotifyButton, logOutSpotifyButton] {
			button.backgroundColor = UIColor.tempoLightRed
			button.layer.cornerRadius = 5.0
			button.layer.masksToBounds = true
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		removeRevealGesture()
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				SpotifyController.sharedController.setSpotifyUser(session.accessToken)
				
				let currentSpotifyUser = User.currentUser.currentSpotifyUser
				self.nameLabel.text = currentSpotifyUser!.username
				self.nameLabel.font = nameLabel.font.fontWithSize(18)
				currentSpotifyUser!.loadImage {
					self.profilePicture.image = $0
				}
			}
			
			loggedInToSpotify(session.isValid())
		} else {
			loggedInToSpotify(false)
		}
	}
    
    func loggedInToSpotify(loggedIn: Bool) {
        let elements = [profilePicture, nameLabel, createPlaylistSwitch, goToSpotifyButton, logOutSpotifyButton]
        loginToSpotifyButton.hidden = loggedIn
        loginText.hidden = loggedIn
        for e in elements {
            e.hidden = !loggedIn
        }
    }
    
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success {
				self.updateSpotifyState()
			} 
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
