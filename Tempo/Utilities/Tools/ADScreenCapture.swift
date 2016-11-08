//
//  ADScreenCapture.swift
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Dennis Fedorko. All rights reserved.
//

import UIKit

class ADScreenCapture: UIView {
    
    func getScreenshot() -> UIImage {
        let layer = UIApplication.shared.keyWindow?.layer as CALayer!
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions((layer?.frame.size)!, false, scale)
        
		guard let context = UIGraphicsGetCurrentContext() else { print("Can't create context: " + #function); return UIImage() }
        
        layer?.render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot!
    }
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		isUserInteractionEnabled = false
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

}
