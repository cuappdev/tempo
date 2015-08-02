//
//  APIViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class APIViewController: UIViewController {

	// TODO: Work on this as a test class for API calls
	// TODO: Create unit tests for API
	
    @IBAction func sendRequest(sender: AnyObject) {
		API.sharedAPI.getCurrentUser { currentUser in
            println(currentUser)
        }
    }
    
    init() {
        super.init(nibName: "APIViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func checkForValidUser(username: String) {
		API.sharedAPI.usernameIsValid("lucasderraugh") { isValid in
			println("Valid Username: \(isValid)")
		}
	}
	
	func updatePost() {
		API.sharedAPI.updatePost(User.currentUser.id, song: Song(spotifyURI: "spotify:track:5EYdTPdJD74r9EVZBztqGG")) {
			println($0)
		}
	}
	
	func fetchUser() {
		API.sharedAPI.fetchUser(User.currentUser.id) {
			println($0)
		}
	}
	
	func fetchFeedOfEveryone() {
		API.sharedAPI.fetchFeedOfEveryone {
			println($0)
		}
	}
}