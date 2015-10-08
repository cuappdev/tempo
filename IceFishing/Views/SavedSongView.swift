//
//  SavedSongView.swift
//  IceFishing
//
//  Created by Jesse Chen on 10/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class SavedSongView: UIView {

	class func instanceFromNib() -> SavedSongView {
		return UINib(nibName: "SavedSongView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SavedSongView
	}

}
