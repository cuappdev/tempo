//
//  HipCalendarCollectionReusableView.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipCalendarCollectionReusableView: UICollectionReusableView {
    
    var titleLabel: UILabel!
    var firstDayOfMonth: NSDate! {
        didSet {
            titleLabel.text = NSDateFormatter.monthFormatter.stringFromDate(firstDayOfMonth).uppercaseString
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var rect = CGRectMake(0, 0, bounds.width/11, bounds.height)
        rect.origin.y = 0.4*frame.size.height
		userInteractionEnabled = false
        
        titleLabel = UILabel(frame: rect)
        titleLabel.textColor = UIColor.tempoDarkRed
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 12)!
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
