//
//  Post.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post: NSObject {
    let user: User
    var player: Player!
    let song: Song
    var date: NSDate?
    var likes = 0

    init(song: Song, user: User, date: NSDate?) {
        self.song = song
        self.user = user
        self.date = date
        
        if let previewURL = song.previewURL {
            player = Player(fileURL: previewURL)
        } else {
            player = Player(fileURL: NSURL(string: "https://p.scdn.co/mp3-preview/004eaa8d0769f3d464992704d9b5c152b862aa65")!)
        }
        
        super.init()
    }
    
    convenience init(json: JSON) {
        let songID = json["song"]["spotify_url"].stringValue
        let user = User(json: json["user"])
        self.init(song: Song(spotifyURI: songID), user: user, date: nil)
    }
    
    func relativeDate() -> String {
        return ""
    }
    
    override var description: String {
        return "\(song.title) posted by \(user.name)"
    }
}
