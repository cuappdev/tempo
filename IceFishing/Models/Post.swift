//
//  Post.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import SwiftyJSON

private let dateFormatter = NSDateFormatter()

class Post: NSObject {
    let user: User
    var player: Player!
    let song: Song
    var date: NSDate?
    var likes = 0
    var postID = ""
    
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
        let dateString = json["created_at"].stringValue
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let date = dateFormatter.dateFromString(dateString)
        self.init(song: Song(spotifyURI: songID), user: user, date: date)
        postID = json["id"].stringValue
    }
    
    func relativeDate() -> String {
        return ""
    }
    
    override var description: String {
        return "\(song.title) posted by \(user.name)"
    }
    
    func like() {
        println(postID)
        API.sharedAPI.updateLikes(postID, unlike: false, completion: {
            (response) in
            println(response)
        })
    }
    
    func unlike() {
        API.sharedAPI.updateLikes(postID, unlike: true, completion: {
            (response) in
            println(response)
        })
    }
}
