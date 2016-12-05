//
//  PostHistoryHeaderSectionCell.swift
//  Tempo
//
//  Created by Logan Allen on 9/23/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PostHistoryHeaderSectionCell: UITableViewCell {
	
	@IBOutlet weak var postDate: UILabel?
	@IBOutlet weak var customSeparator: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
		
		contentView.backgroundColor = .readCellColor
    }
	
}
