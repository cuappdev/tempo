//
//  NSLayoutContraint+Fill.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 8/1/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	
	class func constraintsToFillSuperview(view: UIView) -> [NSLayoutConstraint]{
		view.translatesAutoresizingMaskIntoConstraints = false
		
		var constraints: [NSLayoutConstraint] = []
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v" : view]) 
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v" : view]) 
		
		return constraints
	}
}
