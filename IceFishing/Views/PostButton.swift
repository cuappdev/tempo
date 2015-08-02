//
//  PostButton.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/1/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class PostButton: UIControl {
	
	@IBOutlet private var titleField: UILabel!

	override init(frame: CGRect) {
		fatalError("Must use +instanceFromNib")
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
	class func instanceFromNib() -> PostButton {
		return UINib(nibName: reflect(self).summary.pathExtension, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PostButton
	}
	
	var title: String {
		set { titleField.text = title }
		get { return titleField.text ?? "" }
	}
}
