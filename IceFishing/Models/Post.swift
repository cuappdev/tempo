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
    var likes: Int
    var postID = ""
    
    init(song: Song, user: User, date: NSDate?, likes: Int) {
        self.song = song
        self.user = user
        self.date = date
        self.likes = likes
        
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
        let likes = json["like_count"].intValue
        let date = NSDateFormatter.parsingDateFormatter.dateFromString(dateString)
                
        self.init(song: Song(spotifyURI: songID), user: user, date: date, likes: likes)
        
        postID = json["id"].stringValue
    }
    
    func relativeDate() -> String {
        let now = NSDate()
        let seconds = now.timeIntervalSinceDate(self.date!)
        if seconds < 60 {
            return "just now"
        }
        let minutes: Int = Int(seconds/60)
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours: Int = minutes/60
        if hours < 24 {
            return "\(hours) hr"
        }
        let days: Int = hours/24
        if days < 30 {
            return "\(days) days"
        }
        return "..."
    }
    
    override var description: String {
        return "\(song.title) posted by \(user.name)"
    }
    
    func like() {
        API.sharedAPI.updateLikes(postID, unlike: false, completion: {
            (response) in
            if let success = response["success"] {
                print("successfully liked")
            } else {
                print("failed to like post")
            }
        })
    }
    
    func unlike() {
        API.sharedAPI.updateLikes(postID, unlike: true, completion: {
            (response) in
            if let success = response["success"] {
                
            } else {
                print("failed to like post")
            }
        })
    }
}
