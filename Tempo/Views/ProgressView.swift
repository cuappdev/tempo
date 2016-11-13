//
//  ProgressView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

enum Type {
	case NormalPlayer
	case ExpandedPlayer
}

class ProgressView: UIView {
	
	var playerDelegate: PostDelegate!
	let fillColor = UIColor.tempoLightRed
	private var updateTimer: NSTimer?
	var indicator: UIView?
	
	override func drawRect(rect: CGRect) {
		let progress = playerDelegate.currentPost?.player.progress ?? 0.0
		let fill = bounds.width * CGFloat(progress)
		
		super.drawRect(rect)
		fillColor.setFill()
		CGContextFillRect(UIGraphicsGetCurrentContext(),
			CGRect(x: 0, y: 0, width: fill, height: bounds.height))
		if let indicator = indicator {
			indicator.center.x = frame.origin.x + fill
		}
	}
	
	dynamic private func timerFired(timer: NSTimer) {
		if playerDelegate.currentPost?.player.isPlaying ?? false {
			setNeedsDisplay()
		}
	}
	
	func setUpTimer() {
		if updateTimer == nil && playerDelegate.currentPost?.player.isPlaying ?? false {
			// 60 fps
			updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
								  target: self, selector: #selector(timerFired(_:)),
								  userInfo: nil,
								  repeats: true)
			
			NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
		} else if !(playerDelegate.currentPost?.player.isPlaying ?? false) {
			updateTimer?.invalidate()
			updateTimer = nil
		}
		
	}
}
