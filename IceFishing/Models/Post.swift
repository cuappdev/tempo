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

    init(song: Song, posterFirst: String, posterLast: String) {
        self.song = song
        self.posterFirstName = posterFirst
        self.posterLastName = posterLast
        player = Player(fileURL: song.previewURL)
        super.init()
    }
    
    override init() {
        assertionFailure("Use the init(song:) method instead")
    }
}
