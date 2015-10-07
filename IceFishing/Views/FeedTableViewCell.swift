//
//  FeedTableViewCell.swift
//  experience
//
//  Created by Mark Bryan on 3/22/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet var postView: PostView!
    
    weak var referenceFeedViewController: FeedViewController!
    var savedSongAlertView: SavedSongView!
    
    @IBAction func saveButtonClicked(sender: UIButton) {
        referenceFeedViewController.saveButtonClicked()
    }
}
