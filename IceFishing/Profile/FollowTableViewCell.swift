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
        self.backgroundColor = UIColor.iceDarkGray()
        separator.backgroundColor = UIColor.iceLightGray()
        
        userImage.layer.cornerRadius = userImage.bounds.size.width/2
        userImage.clipsToBounds = true
    }
    
    @IBAction func userImageClicked(sender: UIButton) {
        
        
        
    }

    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
        if (selected) {
            self.contentView.backgroundColor = UIColor.iceLightGray()
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
        }
    }

}

