//
//  SearchSongTableViewCell.swift
//  IceFishing
//
//  Created by Austin Chan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class SearchSongTableViewCell: UITableViewCell {
    var callBack: ((isPlaying: Bool, sender: SearchSongTableViewCell) -> Void)?
    @IBOutlet var postView: SearchPostView!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        backgroundColor = UIColor.iceLightGray()
    }
}
