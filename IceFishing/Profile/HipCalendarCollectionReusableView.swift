//
//  HipCalendarCollectionReusableView.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipCalendarCollectionReusableView: UICollectionReusableView {
    
    var dateFormat: String! = "MMM"
    var titleLabel: UILabel!
    var firstDayOfMonth: NSDate! {
        didSet {
            self.titleLabel.text = firstDayOfMonth.timeDescription(dateFormat).uppercaseString
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var rect: CGRect = CGRectMake(0, 0, self.bounds.width/11, self.bounds.height)
        rect.origin.y = 0.4*frame.size.height
        
        titleLabel = UILabel(frame: rect)
        titleLabel.textColor = UIColor.iceDarkRed()
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 12)!
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        self.addSubview(titleLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
