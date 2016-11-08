//
//  NSLayoutContraint+Fill.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/1/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	
	class func constraintsToFillSuperview(_ view: UIView) -> [NSLayoutConstraint]{
		view.translatesAutoresizingMaskIntoConstraints = false
		
		var constraints: [NSLayoutConstraint] = []
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v" : view])
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v" : view])
		
		return constraints
	}
}
