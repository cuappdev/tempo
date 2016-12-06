//
//  HipCalendarDayCollectionViewCell.swift
//  Tempo
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
<<<<<<< a99dec6ff71380bddfd628c68bc26928d124552f
	let noPostColor: UIColor = .postHistoryGrey
=======
	let noPostColor: UIColor = .unreadCellColor
>>>>>>> Remove ProfileVC xib and style vc
	let circleColor: UIColor = .tempoRed
    var date: Date! {
        didSet {
            dayLabel.text = HipCalendarDayStringFromDate(date)
            dayLabel.textColor = .white
            dayInnerCircleView.backgroundColor = noPostColor
            dayLabel.font = UIFont(name: isToday() ? "AvenirNext-DemiBold" : "AvenirNext-Regular", size: 13.0)
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dayInnerCircleViewInset = contentView.bounds.size.height * 0.2
        dayInnerCircleView = UIView(frame: contentView.bounds.insetBy(dx: dayInnerCircleViewInset, dy: dayInnerCircleViewInset))
        dayInnerCircleView.layer.cornerRadius = dayInnerCircleView.bounds.height / 2
        contentView.addSubview(dayInnerCircleView)
        
        dayLabel = UILabel(frame: bounds)
        dayLabel.textAlignment = .center
        contentView.addSubview(dayLabel)
		isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func isToday() -> Bool {
        return (date.month() == Date().month() && date.day() == Date().day() && date.year() == Date().year())
    }
    
    fileprivate func HipCalendarDayStringFromDate(_ date: Date) -> String {
        return String(format: "%d", date.day())
    }
    
}
