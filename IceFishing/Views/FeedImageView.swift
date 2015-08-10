//
//  FeedImageView.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/29/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class FeedImageView: UIImageView {
	var placeholderImage: UIImage?
	var imageURL: NSURL? {
		didSet {
			if imageURL == oldValue {
				return
			}
			
			if let imageURL = imageURL {
				loadImageAsync(imageURL) { [weak self] (image, error) -> () in
					// This approach is lame and should be moved to cancelable requests
					if self?.imageURL == imageURL && error == nil {
						self?.image = image
					}
				}
			}
		}
	}
	private(set) var progressIndicator = UIProgressView(frame: CGRectZero)
	
	//    override func layoutSubviews() {
	//        super.layoutSubviews()
	//        progressIndicator.frame = bounds
	//    }
}
