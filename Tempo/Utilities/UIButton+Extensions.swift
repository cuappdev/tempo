//
//  UIButton+Extensions.swift
//  Tempo
//
//  Created by Austin Astorga on 12/1/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation

extension UIButton {
	override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let relativeFrame = self.bounds
		let hitTestEdgeInsets = (self.tag == 0) ? UIEdgeInsetsMake(0, 0, 0, 0) : UIEdgeInsetsMake(-20, -20, -20, -20)
		let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
		return hitFrame.contains(point)
	}
}
