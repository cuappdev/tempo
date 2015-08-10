//
//  SongSearchTableViewCell.swift
//  IceFishing
//
//  Created by Austin Chan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class SongSearchTableViewCell: UITableViewCell {
    @IBOutlet var postView: SearchPostView!
	
	override func prepareForReuse() {
		postView.setNeedsDisplay()
	}
}
