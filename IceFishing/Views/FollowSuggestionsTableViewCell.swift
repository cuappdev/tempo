//
//  FollowSuggestionsTableViewCell.swift
//  IceFishing
//
//  Created by Jesse Chen on 11/22/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class FollowSuggestionsTableViewCell: UITableViewCell {
	
	var delegate: SuggestedFollowersDelegate?

	@IBOutlet weak var userImage: UIImageView!
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var userHandle: UILabel!
	@IBOutlet weak var numFollowLabel: UILabel!
	@IBOutlet weak var separator: UIView!
	@IBOutlet weak var followButton: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		contentView.backgroundColor = UIColor.tempoLightGray
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
		self.selectionStyle = UITableViewCellSelectionStyle.None
    }
	
	override func prepareForReuse() {
		userImage.image = nil
	}
    
    @IBAction func didTapFollowButton(sender: UIButton) {
        delegate?.didTapFollowButton(self)
    }
}
