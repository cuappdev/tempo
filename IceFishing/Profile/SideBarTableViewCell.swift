//
//  SideBarTableViewCell.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SideBarTableViewCell: UITableViewCell {

    @IBOutlet weak var categorySymbol: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectedCellView: UIView!
    @IBOutlet weak var customSeparator: UIView!
    
    override func didMoveToSuperview() {
        selectionStyle = .None
        self.backgroundColor = UIColor.iceDarkGray
        customSeparator.backgroundColor = UIColor.iceLightGray
        selectedCellView.frame = CGRectMake(0, 0, 8, self.frame.size.height + 10)
        selectedCellView.backgroundColor = UIColor.iceDarkRed
    }
    
    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
        if (selected) {
            self.contentView.backgroundColor = UIColor.iceLightGray
            selectedCellView.hidden = false
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
            selectedCellView.hidden = true
        }
    }
    
}
