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
        selectionStyle = .none
        backgroundColor = UIColor.tempoDarkGray
        customSeparator.backgroundColor = UIColor.separatorGray
        selectedCellView.frame = CGRect(x: 0, y: 0, width: 8, height: frame.height + 10)
        selectedCellView.backgroundColor = UIColor.tempoLightRed
    }
    
    // Custom selected cell view
    override func setSelected(_ selected: Bool, animated: Bool) {
		contentView.backgroundColor = selected ? UIColor.tempoLightGray : UIColor.clear
		selectedCellView.isHidden = !selected
    }
    
}
