//
//  TrackSearchController.swift
//  IceFishing
//
//  Created by Austin Chan on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class TrackSearchController: UISearchController {

    let kResultSelectionAvatarWidth = 45
    let kResultSelectionHeight = 72
    var bottomView: UIView!
    var selectedTrack: TrackResult!
    var parent: FeedViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        bottomView = UIView(frame: CGRectMake(0, screenSize.height, screenSize.width, CGFloat(kResultSelectionHeight)))
        bottomView.backgroundColor = UIColor.redColor()
        view.addSubview(bottomView)
        
        view.backgroundColor = UIColor.iceDarkGray()

        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("Search to post a song of the Day", comment: "")
        searchBar.showsCancelButton = false
        hidesNavigationBarDuringPresentation = false
    }
    
    func showResultSelection(track: TrackResult) {
        if let previousSelectionView = bottomView.viewWithTag(150) {
            previousSelectionView.removeFromSuperview()
        }
        
        var selectionView = NSBundle.mainBundle().loadNibNamed("SearchResultSelectionView", owner: self, options: nil).first as! UIView

        bottomView.addSubview(selectionView)
        selectionView.frame.size.width = screenSize.width

        UIView.animateWithDuration(0.3, animations: {
            var frame = self.bottomView.frame
            frame.origin.y = screenSize.height - CGFloat(self.kResultSelectionHeight)
            self.bottomView.frame = frame
        })

        var avatarImage = selectionView.viewWithTag(1) as! UIImageView
        var firstLabel = selectionView.viewWithTag(2) as! UILabel
        var secondLabel = selectionView.viewWithTag(3) as! UILabel
        var button = selectionView.viewWithTag(4) as! UIButton

        avatarImage.image = UIImage(named: "Sexy")
        avatarImage.layer.cornerRadius = CGFloat(kResultSelectionAvatarWidth)/2
        avatarImage.clipsToBounds = true
        firstLabel.text = "Mark Bryan"
        var secondLine = track.name
        if track.artists.count > 0 {
            secondLine += " · " + track.artists[0]["name"]!
        }
        secondLabel.text = secondLine
        
        button.addTarget(self, action: "submitTrack", forControlEvents: UIControlEvents.TouchUpInside)
        
        selectedTrack = track
    }
    
    func submitTrack() {
        parent.postSong(selectedTrack)
        bottomView.removeFromSuperview()
    }
    
    func animateOutBottomView() {
        
    }

}
