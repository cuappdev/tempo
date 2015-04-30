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
    let posterFirstName: String
    let posterLastName: String
    var avatar: UIImage?
    var player: Player!
    let song: Song
    var date: NSDate?
    var likes = 0

    init(song: Song, posterFirst: String, posterLast: String, date: NSDate?, avatar: UIImage?) {
        self.song = song
        self.posterFirstName = posterFirst
        self.posterLastName = posterLast
        self.date = date
        self.avatar = avatar
        
        if let previewURL = song.previewURL {
            player = Player(fileURL: previewURL)
        } else {
            player = Player(fileURL: NSURL(string: "https://p.scdn.co/mp3-preview/004eaa8d0769f3d464992704d9b5c152b862aa65")!)
        }
        
        super.init()
    }
    
    convenience init(json: JSON) {
        let songID = json["song"]["spotify_url"].stringValue
        let name = split(json["user"]["name"].stringValue) { $0 == " " }
        let first = name.first ?? ""
        let last = name.count > 1 ? name.last! : ""
        self.init(song: Song(spotifyURI: songID), posterFirst: first, posterLast: last, date: nil, avatar: nil)
    }
    
    func relativeDate() -> String {
        return ""
    }
    
    override var description: String {
        return "\(song.title) posted by \(posterFirstName) \(posterLastName)"
    }
}
