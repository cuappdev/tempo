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

    override func viewDidLoad() {
        super.viewDidLoad()

		beginIceFishing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let session = SPTAuth.defaultInstance().session {
			print("We have a session")
			print("Expires on :\(session.expirationDate)")
			if session.isValid() {
				print("Session is valid")
				label.text = "Session is valid"
			} else {
				print("Session isn't valid")
				SPTAuth.defaultInstance().renewSession(session, callback: { (error, session) -> Void in
					if error == nil {
						print("Session was renewed")
					} else {
						print(error)
					}
				})
			}
			
		}
	}
	
	@IBAction func loginToSpotify(sender: UIButton) {
		let loginURL = SPTAuth.defaultInstance().loginURL
		UIApplication.sharedApplication().openURL(loginURL)
	}
}
