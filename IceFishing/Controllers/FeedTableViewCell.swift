//
//  FeedTableViewCell.swift
//  AppFeed
//
//  Created by Dennis Fedorko on 3/8/15.
//  Copyright (c) 2015 Dennis F. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    //Info
    var songName:String!
    var userWhoSharedThis:String!
    var songArtist:String!
    var shareTime:String!
    var songImage:UIImage!
    
    //Views/Labels
    var songImageView:UIImageView!
    var songInfoLabel:UILabel!
    var shareTimeLabel:UILabel!
    var userWhoSharedLabel:UILabel!
    
    
    //Constants  - ratio to height
    let photoDiameterRatio:CGFloat = 0.8
    let userLabelHeightRatio:CGFloat = 0.2
    let songInfoLabelHeightRatio:CGFloat = 0.2
    let shareTimeLabelHeightRatio:CGFloat = 0.2
    let labelInsetRatio:CGFloat = 1.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setUpCell(songName:String, songArtist:String, songImage:UIImage, shareTime:String, userWhoSharedThis:String) {
        
        self.songName = songName
        self.songArtist = songArtist
        self.songImage = songImage
        self.shareTime = shareTime
        self.userWhoSharedThis = userWhoSharedThis
        
        setUpViewsAndLabels()
    }
    
    func setUpViewsAndLabels() {
        
        songImageView = UIImageView(frame: CGRectMake((frame.height - (frame.height * photoDiameterRatio))/2.0, 0, photoDiameterRatio * frame.height, photoDiameterRatio * frame.height))
        songImageView.center = CGPointMake(songImageView.center.x, frame.height * 0.5)
        songImageView.layer.cornerRadius = songImageView.frame.width/2.0
        songImageView.clipsToBounds = true
        songImageView.image = songImage
        
        userWhoSharedLabel = UILabel(frame: CGRectMake(labelInsetRatio * frame.height, userLabelHeightRatio * frame.height, frame.width - songImageView.frame.width, userLabelHeightRatio * frame.height))
        userWhoSharedLabel.text = userWhoSharedThis
        
        songInfoLabel = UILabel(frame: CGRectMake(labelInsetRatio * frame.height, userWhoSharedLabel.frame.height + userWhoSharedLabel.frame.origin.y, frame.width - songImageView.frame.width, userLabelHeightRatio * frame.height))
        songInfoLabel.text = songName + " : " + songArtist
        
        shareTimeLabel = UILabel(frame: CGRectMake(labelInsetRatio * frame.height, songInfoLabel.frame.height + songInfoLabel.frame.origin.y, frame.width - songImageView.frame.width, userLabelHeightRatio * frame.height))
        shareTimeLabel.text = shareTime
        
        self.addSubview(songImageView)
        self.addSubview(userWhoSharedLabel)
        self.addSubview(songInfoLabel)
        self.addSubview(shareTimeLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
