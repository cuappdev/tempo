//
//  SearchSongTableView.swift
//  IceFishing
//
//  Created by Austin Chan on 5/3/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class SearchSongTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        backgroundColor = UIColor.iceDarkGray
        separatorColor = UIColor.clearColor()
        separatorStyle = .None
        rowHeight = 96
        registerNib(UINib(nibName: "SearchSongTableViewCell", bundle: nil), forCellReuseIdentifier: "searchSongResultsCell")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
