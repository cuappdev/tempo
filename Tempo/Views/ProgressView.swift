//
//  ProgressView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ProgressView: UIView {
	
	var delegate: PostDelegate!
	let fillColor = UIColor.tempoLightRed
	private var updateTimer: NSTimer?
	
	override func drawRect(rect: CGRect) {
		let progress = delegate.post?.player.progress ?? 0
		
		super.drawRect(rect)
		fillColor.setFill()
		CGContextFillRect(UIGraphicsGetCurrentContext(),
			CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height))
	}
	
	dynamic private func timerFired(timer: NSTimer) {
		if delegate.post?.player.isPlaying ?? false {
			setNeedsDisplay()
		}
	}
	
	func setUpTimer() {
		if updateTimer == nil && delegate.post?.player.isPlaying ?? false {
			// 60 fps
			updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
			                      target: self, selector: #selector(timerFired(_:)),
			                      userInfo: nil,
			                      repeats: true)
			
			NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
		} else if !(delegate.post?.player.isPlaying ?? false) {
			updateTimer?.invalidate()
			updateTimer = nil
		}
		
	}
}
