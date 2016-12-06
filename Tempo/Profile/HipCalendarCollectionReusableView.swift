//
//  HipCalendarCollectionReusableView.swift
//  Tempo
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class HipCalendarCollectionReusableView: UICollectionReusableView {
    
    var titleLabel: UILabel!
    var firstDayOfMonth: Date! {
        didSet {
            titleLabel.text = DateFormatter.monthFormatter.string(from: firstDayOfMonth).uppercased()
        }
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var rect = CGRect(x: 0, y: 0, width: bounds.width/11, height: bounds.height)
        rect.origin.y = 0.4*frame.size.height
		isUserInteractionEnabled = false
        
        titleLabel = UILabel(frame: rect)
        titleLabel.textColor = .tempoRed
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 13.0)!
        titleLabel.textAlignment = .center
        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
