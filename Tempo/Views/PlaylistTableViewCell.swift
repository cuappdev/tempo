//
//  PlaylistTableViewCell.swift
//  Tempo
//
//  Created by Annie Cheng on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

	@IBOutlet weak var playlistImage: UIImageView!
	@IBOutlet weak var playlistNameLabel: UILabel!
	@IBOutlet weak var playlistNumSongsLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		contentView.backgroundColor = UIColor.tempoLightGray
		separator.backgroundColor = UIColor.separatorGray
		separatorHeight.constant = 0.5
	}
    
}
