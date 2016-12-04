//
//  SavedSongView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SavedSongView: UIView {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
	class func instanceFromNib() -> SavedSongView {
		return UINib(nibName: "SavedSongView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SavedSongView
	}
	
	func addSongtoPlaylist(_ playlist: String) {
		statusImage.image = #imageLiteral(resourceName: "SavedIcon")
		statusLabel.text = "Added to \(playlist)"
	}
	
	func saveSongToYourMusic() {
		statusImage.image = #imageLiteral(resourceName: "SavedIcon")
		statusLabel.text = "Saved to\nYour Music"
	}
	
	func removeSongfromSaved() {
		statusImage.image = #imageLiteral(resourceName: "RemovedIcon")
		statusLabel.text = "Removed from Your Music"
	}
	
	func showSongStatusPopup(_ status: SavedSongStatus, playlist: String) {
		let currentWindow = UIApplication.shared.keyWindow
		let screenWidth = currentWindow!.frame.size.width
		let screenHeight = currentWindow!.frame.size.height
		let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

		center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
		layer.cornerRadius = 10
		alpha = 0
		
		if status == .notSaved {
			saveSongToYourMusic()
		} else if status == .saved {
			removeSongfromSaved()
		} else if status == .notSavedToPlaylist {
			addSongtoPlaylist(playlist)
		}
		
		currentWindow?.addSubview(self)
		
		fadeIn(0.5, delay: 0) { _ in
			DispatchQueue.main.asyncAfter(deadline: delayTime) {
				self.fadeOut(0.5, delay: 0) { _ in
					self.removeFromSuperview()
				}
			}
		}
	}
	
}
