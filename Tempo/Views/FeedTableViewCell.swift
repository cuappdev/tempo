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
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		postView.backgroundColor = .unreadCellColor
		separator.backgroundColor = .readCellColor
		separatorHeight.constant = 1
	}
	
	func setUpCell(firstName: String, lastName: String) {
		initialsLabel.text = setUserInitials(firstName: firstName, lastName: firstName)
	}
}
