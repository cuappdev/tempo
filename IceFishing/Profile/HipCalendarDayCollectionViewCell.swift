//
//  HipCalendarDayCollectionViewCell.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipCalendarDayCollectionViewCell: UICollectionViewCell {
    
    // UIViews
    var dayLabel: UILabel!
    var dayCircleView: UIView!
    var dayInnerCircleView: UIView!
    
    // Colors
    var noPostColor : UIColor! = UIColor.iceDarkGray
    var circleColor : UIColor! = UIColor.iceDarkRed   
    var date: NSDate! {
        didSet {
            dayLabel.text = HipCalendarDayStringFromDate(date)
            dayLabel.textColor = UIColor.whiteColor()
            dayInnerCircleView.backgroundColor = noPostColor
            
            if isToday() {
                dayLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
            } else {
                dayLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
            }
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dayInnerCircleViewInset = contentView.bounds.size.height * 0.2
        dayInnerCircleView = UIView(frame: CGRectInset(contentView.frame, dayInnerCircleViewInset, dayInnerCircleViewInset))
        dayInnerCircleView.layer.cornerRadius = CGRectGetHeight(dayInnerCircleView.bounds) / 2
        contentView.addSubview(dayInnerCircleView)
        
        dayLabel = UILabel(frame: self.bounds)
        dayLabel.textAlignment = NSTextAlignment.Center
        contentView.addSubview(dayLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func isToday() -> Bool {
        return (date.month() == NSDate().month() && date.day() == NSDate().day() && date.year() == NSDate().year())
    }
    
    private func HipCalendarDayStringFromDate(date: NSDate) -> String {
        return String(format: "%d", date.day())
    }
    
}
