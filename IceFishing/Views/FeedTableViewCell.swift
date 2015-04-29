//
//  FeedTableViewCell.swift
//  experience
//
//  Created by Mark Bryan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    var callBack: ((isPlaying: Bool, sender: FeedTableViewCell) -> Void)?
    @IBOutlet var postView: PostView!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        backgroundColor = UIColor.iceLightGray()
//        var tapRecognizer = UITapGestureRecognizer(target: self, action: "cellPressed:")
//        addGestureRecognizer(tapRecognizer)
    }
}
