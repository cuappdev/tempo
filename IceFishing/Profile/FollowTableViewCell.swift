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
    @IBOutlet weak var separator: UIView!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        self.backgroundColor = UIColor(red: 43.0/255.0, green: 73.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        separator.backgroundColor = UIColor(red: 19.0/255.0, green: 39.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        
        userImage.layer.cornerRadius = userImage.bounds.size.width/2
        userImage.clipsToBounds = true
        
        userImage.userInteractionEnabled = true
        userName.userInteractionEnabled = true
    }

}

