//
//  SavedSongView.swift
//  IceFishing
//
//  Created by Jesse Chen on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SavedSongView: UIView {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
	class func instanceFromNib() -> SavedSongView {
		return UINib(nibName: "SavedSongView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SavedSongView
	}
	
	func addSongtoPlaylist(playlist: String) {
		statusImage.image = UIImage(named: "Saved-Check")
		statusLabel.text = "Added to \(playlist)"
	}
	
	func saveSongToYourMusic() {
		statusImage.image = UIImage(named: "Saved-Check")
		statusLabel.text = "Saved to\nYour Music"
	}
	
	func removeSongfromSaved() {
		statusImage.image = UIImage(named: "Saved-Cross")
		statusLabel.text = "Removed from Your Music"
	}
	
	func showSongStatusPopup(status: SavedSongStatus, playlist: String) {
		let currentWindow = UIApplication.sharedApplication().keyWindow
		let screenWidth = currentWindow!.frame.size.width
		let screenHeight = currentWindow!.frame.size.height
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))

		center = CGPointMake(screenWidth / 2, screenHeight / 2)
		layer.cornerRadius = 10
		alpha = 0.0
		
		if status == .NotSaved {
			saveSongToYourMusic()
		} else if status == .Saved {
			removeSongfromSaved()
		} else if status == .NotSavedToPlaylist {
			addSongtoPlaylist(playlist)
		}
		
		currentWindow?.addSubview(self)
		
		self.fadeIn(0.5, delay: 0.0, completion: { _ in
			dispatch_after(delayTime, dispatch_get_main_queue(), {
				self.fadeOut(0.5, delay: 0.0, completion: { _ in
					self.removeFromSuperview()
				})
			})
		})
	}
	
}
