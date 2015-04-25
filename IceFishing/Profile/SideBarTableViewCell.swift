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
        self.backgroundColor = UIColor(red: 19.0 / 255.0, green: 39.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
        customSeparator.backgroundColor = UIColor(red: 43.0 / 255.0, green: 73.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        selectedCellView.frame = CGRectMake(0, 0, 8, self.frame.size.height + 10)
        selectedCellView.backgroundColor = UIColor(red: 181.0 / 255.0, green: 87.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
    }
    
    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
        if (selected) {
            self.contentView.backgroundColor = UIColor(red: 43.0 / 255.0, green: 73.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
            selectedCellView.hidden = false
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
            selectedCellView.hidden = true
        }
    }
    
}
