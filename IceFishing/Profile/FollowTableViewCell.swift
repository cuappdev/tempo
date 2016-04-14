//
//  FollowTableViewCell.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/19/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

protocol FollowUserDelegate {
	func didTapFollowButton(cell: FollowTableViewCell)
}

class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var numFollowLabel: UILabel!
    @IBOutlet weak var separator: UIView!
	@IBOutlet weak var followButton: UIButton!
	
	var delegate: FollowUserDelegate?
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        backgroundColor = UIColor.iceDarkGray
        separator.backgroundColor = UIColor.iceLightGray
        
        userImage.layer.cornerRadius = userImage.bounds.size.width/2
        userImage.clipsToBounds = true
    }
    
    @IBAction func userImageClicked(sender: UIButton) {
        
        
        
    }

    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? UIColor.iceLightGray : UIColor.clearColor()
    }
	
	@IBAction func didTapFollowButton(sender: AnyObject) {
		delegate?.didTapFollowButton(self)
	}
}

