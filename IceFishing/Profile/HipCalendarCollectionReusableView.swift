//
//  HipCalendarCollectionReusableView.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipCalendarCollectionReusableView: UICollectionReusableView {
    
    var dateFormat: String! = "MMM YYYY"
    var titleLabel: UILabel!
    var firstDayOfMonth: NSDate! {
        didSet {
            self.titleLabel.text = firstDayOfMonth.timeDescription(dateFormat).uppercaseString
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var rect: CGRect = self.bounds
        rect.size.height = 30.0
        rect.origin.y = frame.size.height - rect.size.height
        
        titleLabel = UILabel(frame: rect)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        titleLabel.textColor = UIColor.whiteColor()
        self.addSubview(titleLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
