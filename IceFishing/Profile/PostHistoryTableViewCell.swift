//
//  PostHistoryTableViewCell.swift
//  Tempo
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class PostHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var postedSongImage: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel! 
    @IBOutlet weak var separator: PostView!
	
    override func didMoveToSuperview() {
        selectionStyle = .None
        backgroundColor = UIColor.tempoDarkGray
        separator.backgroundColor = UIColor.separatorGray
		postedSongImage.layer.cornerRadius = postedSongImage.bounds.size.width/2
        postedSongImage.clipsToBounds = true
    }
    
    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? UIColor.tempoLightGray : UIColor.clearColor()
    }
    
}
