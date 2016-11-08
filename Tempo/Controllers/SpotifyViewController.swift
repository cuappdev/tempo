//
//  SpotifyViewController.swift
//  Tempo
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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		title = "Spotify"
		addHamburgerMenu()
		updateSpotifyState()
		
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor.white.cgColor
        createPlaylistSwitch.tintColor = UIColor.tempoLightRed
        createPlaylistSwitch.onTintColor = UIColor.tempoLightRed
		
		for button in [loginToSpotifyButton, goToSpotifyButton, logOutSpotifyButton] {
			button?.backgroundColor = UIColor.tempoLightRed
			button?.layer.cornerRadius = 5.0
			button?.layer.masksToBounds = true
		}
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				SpotifyController.sharedController.setSpotifyUser(session.accessToken)
				
				let currentSpotifyUser = User.currentUser.currentSpotifyUser
				self.nameLabel.text = currentSpotifyUser!.username
				self.nameLabel.font = nameLabel.font.withSize(18)
			}
			
			loggedInToSpotify(session.isValid())
		} else {
			loggedInToSpotify(false)
		}
	}
    
    func loggedInToSpotify(_ loggedIn: Bool) {
        let elements = [profilePicture, nameLabel, createPlaylistSwitch, goToSpotifyButton, logOutSpotifyButton]
        loginToSpotifyButton.isHidden = loggedIn
        loginText.isHidden = loggedIn
        for e in elements {
            e?.isHidden = !loggedIn
        }
    }
    
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success {
				self.updateSpotifyState()
			} 
		}
	}
    
    @IBAction func toggleCreatePlaylistSwitch(_ sender: UISwitch) {
        if sender.isOn {
            
        } else {
            
        }
    }
    
    @IBAction func goToSpotify(_ sender: UIButton) {
        SpotifyController.sharedController.openSpotifyURL()
    }
    
    @IBAction func logOutSpotify(_ sender: UIButton) {
        SpotifyController.sharedController.closeCurrentSpotifySession()
		
        updateSpotifyState()
    }
	
}
