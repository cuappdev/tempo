//
//  PlaylistTableViewCell.swift
//  IceFishing
//
//  Created by Annie Cheng on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

	@IBOutlet weak var playlistImage: UIImageView!
	@IBOutlet weak var playlistNameLabel: UILabel!
	@IBOutlet weak var playlistNumSongsLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
