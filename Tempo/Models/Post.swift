//
//  Post.swift
//  Tempo
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
    let date: Date?
    fileprivate(set) var likes: Int
	fileprivate(set) var isLiked: Bool = false
	fileprivate(set) var postID: String = ""
	
	init(song: Song, user: User, date: Date? = nil, likes: Int = 0, isLiked: Bool = false) {
        self.song = song
        self.user = user
        self.date = date
        self.likes = likes
		self.isLiked = isLiked
        
        if let previewURL = song.previewURL {
            player = Player(fileURL: previewURL)
        } else {
            player = Player(fileURL: URL(string: "https://p.scdn.co/mp3-preview/004eaa8d0769f3d464992704d9b5c152b862aa65")!)
        }
        
        super.init()
    }
    
    convenience init(json: JSON) {
        let songID = json["song"]["spotify_url"].stringValue
        let user = User(json: json["user"])
        let dateString = json["created_at"].stringValue
        let likes = json["like_count"].intValue
		let isLiked = json["post"]["is_liked"].boolValue
        let date = DateFormatter.parsingDateFormatter.date(from: dateString)
                
		self.init(song: Song(spotifyURI: songID), user: user, date: date, likes: likes, isLiked: isLiked)
		
        postID = json["id"].stringValue
    }
    
    func relativeDate() -> String {
		guard let date = date else { return "" }
        let now = Date()
        let seconds = Int(now.timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        if minutes == 1 {
            return "\(minutes)m"
        }
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours: Int = minutes / 60
        if hours == 1 {
            return "\(hours)h"
        }
        if hours < 24 {
            return "\(hours)h"
        }
        let days: Int = hours / 24
        if days == 1 {
            return "\(days)d"
        }
        return "\(days)d"
    }
    
    override var description: String {
        return "\(song.title) posted by \(user.name)"
    }
	
	func toggleLike() {
		isLiked = !isLiked
		likes += isLiked ? 1 : -1
		API.sharedAPI.updateLikes(postID, unlike: !isLiked)
	}
}
