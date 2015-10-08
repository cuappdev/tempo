//
//  UserTableViewCell.swift
//  IceFishing
//
//  Created by Annie Cheng on 9/16/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    var user: User!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .None
		self.backgroundColor = UIColor.iceDarkGray
		separator.backgroundColor = UIColor.iceLightGray
		
		userImage.layer.cornerRadius = userImage.bounds.size.width/2
		userImage.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
