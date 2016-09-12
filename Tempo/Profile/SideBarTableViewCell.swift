//
//  SideBarTableViewCell.swift
//  Tempo
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
        backgroundColor = UIColor.tempoDarkGray
        customSeparator.backgroundColor = UIColor.separatorGray
        selectedCellView.frame = CGRectMake(0, 0, 8, frame.height + 10)
        selectedCellView.backgroundColor = UIColor.tempoLightRed
    }
    
    // Custom selected cell view
    override func setSelected(selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? UIColor.tempoLightGray : UIColor.clearColor()
		selectedCellView.hidden = !selected
    }
    
}
