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
	@IBOutlet weak var shareButtonWidthConstraint: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		contentView.backgroundColor = .unreadCellColor
		separator.backgroundColor = .readCellColor
		separatorHeight.constant = 1
		
		shareButton.layer.borderWidth = 1.5
		shareButton.layer.borderColor = UIColor.tempoRed.cgColor
		shareButton.titleLabel?.textColor = UIColor.white.withAlphaComponent(0.87)
		shareButtonWidthConstraint.constant = 0
	}
	
	override func prepareForReuse() {
		postView.setNeedsDisplay()
	}
}
