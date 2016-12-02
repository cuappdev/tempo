//
//  LikedTableViewCell.swift
//  Tempo
//
//  Created by Logan Allen on 11/18/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class LikedTableViewCell: UITableViewCell {
	
	var postView: LikedPostView?
	var separator: UIView?

    override func awakeFromNib() {
		super.awakeFromNib()
    }
	
	func setupCell() {
		selectionStyle = .none
		
		postView = LikedPostView()
		postView?.frame = bounds
		addSubview(postView!)
		
		separator = UIView(frame: CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1))
		separator?.backgroundColor = .backgroundDarkGrey
		addSubview(separator!)
	}

}
