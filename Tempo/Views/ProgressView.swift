//
//  ProgressView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class ProgressView: UIView {
	
	var playerDelegate: PostDelegate!
	let fillColor: UIColor = .tempoRed
	private var updateTimer: Timer?
	var indicator: UIView?
	
	override func draw(_ rect: CGRect) {
		let progress = playerDelegate.getCurrentPost()?.player.progress ?? 0.0
		let fill = bounds.width * CGFloat(progress)
		super.draw(rect)
		fillColor.setFill()

		UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: fill, height: bounds.height))
		if let indicator = indicator {
			indicator.center.x = fill
			indicator.center.y = frame.height / 2.0
		}
	}
	
	dynamic private func timerFired(timer: Timer) {
		if playerDelegate.getCurrentPost()?.player.isPlaying ?? false {
			setNeedsDisplay()
		}
	}
	
	func setUpTimer() {
		if updateTimer == nil && playerDelegate.getCurrentPost()?.player.isPlaying ?? false {
			// 60 fps
			updateTimer = Timer(timeInterval: 1.0 / 60.0,
								  target: self, selector: #selector(timerFired(timer:)),
								  userInfo: nil,
								  repeats: true)
			
			RunLoop.current.add(updateTimer!, forMode: RunLoopMode.commonModes)
		} else if !(playerDelegate.getCurrentPost()?.player.isPlaying ?? false) {
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
}
