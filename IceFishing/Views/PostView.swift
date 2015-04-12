//
//  PostView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class PostView: UIView {
    @IBOutlet var fistNameLabel: UILabel?
    @IBOutlet var lastNameLabel: UILabel?
    @IBOutlet var avatarImageView: UILabel?
    var post: Post? {
        didSet {
            // update stuff
        }
    }
    
}
