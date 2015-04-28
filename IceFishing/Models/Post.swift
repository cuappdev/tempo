//
//  Post.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class Post: NSObject {
    var posterFirstName = ""
    var posterLastName = ""
    var avatar: UIImage?
    var player: Player!
    var song: Song!
    var date: NSDate?

    init(song: Song, posterFirst: String, posterLast: String, date: NSDate?, avatar: UIImage?) {
        self.song = song
        self.posterFirstName = posterFirst
        self.date = date
        self.avatar = avatar
        self.posterLastName = posterLast
        
        if let previewURL = song.previewURL {
            player = Player(fileURL: previewURL)
        } else {
            player = Player(fileURL: NSURL(string: "https://p.scdn.co/mp3-preview/004eaa8d0769f3d464992704d9b5c152b862aa65")!)
        }
        
        super.init()
    }
    
    convenience init(trackResult: TrackResult, posterFirst: String, posterLast: String, date: NSDate?, avatar: UIImage?) {
        self.init(song: Song(spotifyURI: trackResult.id), posterFirst: posterFirst, posterLast: posterLast, date: date, avatar: avatar)
    }
    
    override init() {
        assertionFailure("Use the init(song:...) method instead")
    }
}
