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
	@IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		separator.backgroundColor = UIColor.separatorGray
		separatorHeight.constant = 0.5
	}
	
	override func prepareForReuse() {
		postView.setNeedsDisplay()
	}
}
