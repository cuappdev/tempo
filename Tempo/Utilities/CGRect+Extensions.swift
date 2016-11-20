//
//  CGRect+Extensions.swift
//  Tempo
//
//  Created by Dennis Fedorko on 11/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

extension CGRect {
	
	var top: CGPoint {
		get {
			return CGPoint(x: origin.x + width / 2.0, y: origin.y)
		}
		set (newTop) {
			origin = CGPoint(x: newTop.x - width / 2.0, y: newTop.y)
		}
	}
	
	var bottom: CGPoint {
		get {
			return CGPoint(x: origin.x + width / 2.0, y: origin.y + height)
		}
		set (newBottom) {
			origin = CGPoint(x: newBottom.x - width / 2.0, y: newBottom.y - height)
		}
	}
	
	var left: CGPoint {
		get {
			return CGPoint(x: origin.x, y: origin.y + height / 2.0)
		}
		set (newLeft) {
			origin = CGPoint(x: newLeft.x, y: newLeft.y - height / 2.0)
		}
	}
	
	var right: CGPoint {
		get {
			return CGPoint(x: origin.x + width, y: origin.y + height / 2.0)
		}
		set (newRight) {
			origin = CGPoint(x: newRight.x - width, y: newRight.y - height / 2.0)
		}
	}
	
}
