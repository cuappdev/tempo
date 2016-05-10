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
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	@IBOutlet weak var followButton: UIButton!
	
	var delegate: FollowUserDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .None
		backgroundColor = UIColor.tempoLightGray
		separator.backgroundColor = UIColor.separatorGray
		separatorHeight.constant = 1
		followButton.backgroundColor = UIColor.tempoLightRed
		followButton.layer.borderColor = UIColor.tempoLightRed.CGColor
		userImage.layer.cornerRadius = userImage.bounds.size.width/2
		userImage.clipsToBounds = true
	}
	
    @IBAction func userImageClicked(sender: UIButton) {
        
        
        
    }

    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? UIColor.tempoLightGray : UIColor.clearColor()
    }
	
	@IBAction func didTapFollowButton(sender: AnyObject) {
		delegate?.didTapFollowButton(self)
	}
}

