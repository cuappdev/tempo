//
//  SpotifyViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/9/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SpotifyViewController: UIViewController, SPTAuthViewDelegate {
	
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginToSpotifyButton: UIButton!
    @IBOutlet weak var createPlaylistSwitch: UISwitch!
    @IBOutlet weak var goToSpotifyButton: UIButton!
    @IBOutlet weak var logOutSpotifyButton: UIButton!
	
	var authViewController: SPTAuthViewController?
	
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
		// FIX: Temporary fix for user authentication
		if let session = SPTAuth.defaultInstance().session {
			self.loggedInToSpotify(session.isValid())
		}

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
		authViewController = SPTAuthViewController.authenticationViewController()
		print(authViewController!.view.subviews[0].bounds.size)
		authViewController!.delegate = self
		authViewController!.modalPresentationStyle = .OverCurrentContext
		authViewController!.modalTransitionStyle = .CrossDissolve
		
		modalPresentationStyle = .CurrentContext
		definesPresentationContext = true
		presentViewController(authViewController!, animated: true, completion: nil)
	}
	
	func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
		print("Logged in with session: \(session)")
		updateSpotifyState()
	}
	
	func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
		if error != nil {
			print("Failed to login: \(error)")
		}
	}
	
	func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
		print("Login cancelled")
	}
	
	func renewToken() {
		SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { (error, session) -> Void in
			if error != nil {
				print("error: \(error)")
			} else {
				SPTAuth.defaultInstance().session = session
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
