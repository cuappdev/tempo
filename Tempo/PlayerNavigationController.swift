//
//  PlayerNavigationController.swift
//  Tempo
//
//  Created by Jesse Chen on 10/23/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PlayerNavigationController: UINavigationController {

	var playerCell: PlayerCellView!
	let frameHeight = CGFloat(72)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - 72, UIScreen.mainScreen().bounds.width, frameHeight))
		playerFrame.backgroundColor = UIColor.redColor()
		self.view.addSubview(playerFrame)
		playerCell = NSBundle.mainBundle().loadNibNamed("PlayerCellView", owner: self, options: nil).first as! PlayerCellView
		playerCell.setup()
		playerCell.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, frameHeight)
		playerFrame.addSubview(playerCell)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}
