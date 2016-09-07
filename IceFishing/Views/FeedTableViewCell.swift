//
//  FeedTableViewCell.swift
//  Tempo
//
//  Created by Mark Bryan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
	
    @IBOutlet var postView: PostView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		postView.backgroundColor = UIColor.tempoLightGray
		separator.backgroundColor = UIColor.separatorGray
		separatorHeight.constant = 0.5
	}
}
