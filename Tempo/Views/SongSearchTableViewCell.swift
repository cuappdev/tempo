//
//  SongSearchTableViewCell.swift
//  Tempo
//
//  Created by Austin Chan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class SongSearchTableViewCell: UITableViewCell {
    @IBOutlet var postView: SearchPostView!
	@IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		contentView.backgroundColor = UIColor.tempoLightGray
		separator.backgroundColor = UIColor.separatorGray
		separatorHeight.constant = 0.5
		
		shareButton.layer.borderWidth = 1.5
		shareButton.layer.borderColor = UIColor.tempoLightRed.CGColor
		shareButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 12)!
	}
	
	override func prepareForReuse() {
		postView.setNeedsDisplay()
	}
}
