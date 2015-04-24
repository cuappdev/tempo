//
//  FollowersTableViewCell.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/19/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userhandle: UILabel!
    @IBOutlet weak var numFollowersLabel: UILabel!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        
        userImage.layer.cornerRadius = userImage.bounds.size.width/2
        userImage.clipsToBounds = true
        
        userImage.userInteractionEnabled = true
        username.userInteractionEnabled = true
    }

}

