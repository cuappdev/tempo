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
	@IBOutlet weak var initialsView: UIView!
	@IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	@IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var leadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSpaceConstraint: NSLayoutConstraint!
    
	var delegate: FollowUserDelegate?
	var isFollowSuggestionCell: Bool = false
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .none
		backgroundColor = .unreadCellColor
		
		followButton.backgroundColor = .tempoRed
		followButton.layer.borderColor = UIColor.tempoRed.cgColor
		followButton.layer.borderWidth = 1.5
		followButton.layer.cornerRadius = 3
		followButton.clipsToBounds = true
		userImage.layer.cornerRadius = userImage.bounds.width/2
		userImage.clipsToBounds = true
		separator.backgroundColor = .readCellColor
		separatorHeight.constant = 1
	}
	
	func setUpFollowSuggestionsCell() {
		isFollowSuggestionCell = true
		leadingSpaceConstraint.constant = 14
		trailingSpaceConstraint.constant = 11
		backgroundColor = .cellDarkGrey
		contentView.backgroundColor = .cellDarkGrey
	}
	
	func setUpInitialsView(firstName: String, lastName: String) {
		initialsLabel.text = setUserInitials(firstName: firstName, lastName: lastName)
	}
	
    @IBAction func userImageClicked(_ sender: UIButton) {
		
    }

    // Custom selected cell view
    override func setSelected(_ selected: Bool, animated: Bool) {
		let unselectedColor: UIColor = isFollowSuggestionCell ? .cellDarkGrey : .unreadCellColor
		
		contentView.backgroundColor = selected ? .readCellColor : unselectedColor
    }
	
	@IBAction func didTapFollowButton(_ sender: AnyObject) {
		delegate?.didTapFollowButton(self)
	}
}

