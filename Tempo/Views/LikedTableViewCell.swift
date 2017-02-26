//
//  LikedTableViewCell.swift
//  Tempo
//
//  Created by Logan Allen on 11/18/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class LikedTableViewCell: PostTableViewCell {
	
	var likedPostView: LikedPostView? = nil
	var separator: UIView?

    override func awakeFromNib() {
		super.awakeFromNib()
    }
	
	func setupCell(spotifyAvailable: Bool) {
		selectionStyle = .none
		likedPostView = LikedPostView()
		postView = likedPostView as PostView?
		likedPostView?.frame = bounds
		likedPostView?.isSpotifyAvailable = spotifyAvailable
		addSubview(postView!)
		
		separator = UIView(frame: CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1))
		separator?.backgroundColor = .readCellColor
		addSubview(separator!)
	}

}
