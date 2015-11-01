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
	
	func saveSongToYourMusic() {
		statusImage.image = UIImage(named: "Saved-Check")
		statusLabel.text = "Saved to\nYour Music"
	}
	
	func removeSongfromSaved() {
		statusImage.image = UIImage(named: "Saved-Cross")
		statusLabel.text = "Removed from Your Music"
	}

}
