//
//  FeedTableViewCell.swift
//  Tempo
//
//  Created by Mark Bryan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class FeedTableViewCell: PostTableViewCell {
	
    @IBOutlet weak var feedPostView: FeedPostView!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButtonBottomConstraint: NSLayoutConstraint!
    
	override func awakeFromNib() {
		super.awakeFromNib()
		
		postView?.backgroundColor = .unreadCellColor
		separator.backgroundColor = .readCellColor
		initialsLabel.isHidden = true
		initialsView.isHidden = true
//		separatorHeight.constant = 1
	}
	
	func setUpFeedCell(firstName: String, lastName: String) {
		postView = feedPostView
		initialsLabel.text = setUserInitials(firstName: firstName, lastName: lastName)
	}
	
	func setUpPostHistoryCell() {
		postView = feedPostView
		initialsLabel.text = ""
		feedPostView.dateLabel!.isHidden = true
		feedPostView.avatarImageView?.layer.cornerRadius = 0
//		imageViewWidthConstraint.constant = 60
//		imageViewTopConstraint.constant = 25
//		likeButtonBottomConstraint.constant = 48.5
	}
}
