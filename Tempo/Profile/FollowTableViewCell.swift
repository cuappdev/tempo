//
//  FollowTableViewCell.swift
//  Tempo
//
//  Created by Manuela Rios on 4/19/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

protocol FollowUserDelegate {
	func didTapFollowButton(_ cell: FollowTableViewCell)
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
		
		selectionStyle = .none
		backgroundColor = .unreadCellColor
		
		followButton.backgroundColor = .tempoRed
		followButton.layer.borderColor = UIColor.tempoRed.cgColor
		followButton.layer.borderWidth = 1.5
		userImage.layer.cornerRadius = userImage.bounds.width/2
		userImage.clipsToBounds = true
		separator.backgroundColor = .readCellColor
		separatorHeight.constant = 1
	}
	
    @IBAction func userImageClicked(_ sender: UIButton) {
		
    }

    // Custom selected cell view
    override func setSelected(_ selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? .readCellColor : .unreadCellColor
    }
	
	@IBAction func didTapFollowButton(_ sender: AnyObject) {
		delegate?.didTapFollowButton(self)
	}
}

