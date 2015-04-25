//
//  FollowTableViewCell.swift
//  IceFishing
//
//  Created by Manuela Rios on 4/19/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var numFollowLabel: UILabel!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        
        userImage.layer.cornerRadius = userImage.bounds.size.width/2
        userImage.clipsToBounds = true
        
        userImage.userInteractionEnabled = true
        userName.userInteractionEnabled = true
    }

}

