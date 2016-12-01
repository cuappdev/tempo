//
//  User.swift
//  Tempo
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {
	
	static var currentUser: User = User()
    var currentSpotifyUser: CurrentSpotifyUser?
	
	fileprivate(set) var caption = ""
	fileprivate(set) var createdAt = ""
	fileprivate(set) var email = "temp@example.com"
	fileprivate(set) var fbid = ""
	var remotePushNotificationsEnabled = false
	var isFollowing = false
	var followers: [String] = []
	var followersCount = 0
	var followingCount = 0
	var hipsterScore = 0
	var id = ""
	var likeCount = 0
	var locationID = ""
	var firstName = ""
	var lastName = ""
	var name: String {
		set(newName) {
			let fullName = newName.characters.split { $0 == " " }.map { String($0) }
			firstName = fullName.first ?? ""
			lastName = fullName.count > 1 ? fullName.last! : ""
		}
		get {
			return "\(firstName) \(lastName)"
		}
	}
	var updatedAt: String!
	var username: String = "temp_username"
	fileprivate var profileImage: UIImage?
	var imageURL: URL {
		return URL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
	}
	
	override init() {} 
	
	init(json: JSON) {
		super.init()
		caption = json["caption"].stringValue
		createdAt = json["created_at"].stringValue
		email = json["email"].stringValue
		fbid = json["fbid"].stringValue
		isFollowing = json["is_following"].boolValue
		followers = json["followers"].arrayObject as? [String] ?? []
		followersCount = json["followers_count"].intValue
		followingCount = json["followings_count"].intValue
		hipsterScore = json["hipster_score"].intValue
		id = json["id"].stringValue
		likeCount = json["like_count"].intValue
		locationID = json["location_id"].stringValue
		name = json["name"].stringValue
		updatedAt = json["updated_at"].stringValue
		username = json["username"].stringValue
		remotePushNotificationsEnabled = json["remote_push_notifications_enabled"].boolValue
		currentSpotifyUser = User.currentUser.currentSpotifyUser
	}
	
	override var description: String {
		return "Name: \(name)| Email: \(email)| ID: \(id)| Username: \(username)| FacebookID: \(fbid)"
	}
	
	func shortenLastName()->String{
		if lastName.characters.count > 18{
			return "\(lastName[lastName.startIndex])."
		} else {
			return lastName
		}
	}
	
	// Extend NSCoding
	// MARK: - NSCoding
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		caption = aDecoder.decodeObject(forKey: "caption") as! String
		createdAt = aDecoder.decodeObject(forKey: "created_at") as! String
		email = aDecoder.decodeObject(forKey: "email") as! String
		fbid = aDecoder.decodeObject(forKey: "fbid") as! String
		followers = aDecoder.decodeObject(forKey: "followers") as! [String]
		followersCount = aDecoder.decodeInteger(forKey: "followers_count")
		hipsterScore = aDecoder.decodeInteger(forKey: "hipster_score")
		id = aDecoder.decodeObject(forKey: "id") as! String
		likeCount = aDecoder.decodeInteger(forKey: "like_count")
		locationID = aDecoder.decodeObject(forKey: "location_id") as! String
		name = aDecoder.decodeObject(forKey: "name") as! String
		updatedAt = aDecoder.decodeObject(forKey: "updated_at") as! String
		username = aDecoder.decodeObject(forKey: "username") as! String
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(caption, forKey: "caption")
		aCoder.encode(createdAt, forKey: "created_at")
		aCoder.encode(email, forKey: "email")
		aCoder.encode(fbid, forKey: "fbid")
		aCoder.encode(followers, forKey: "followers")
		aCoder.encode(followersCount, forKey: "followers_count")
		aCoder.encode(hipsterScore, forKey: "hipster_score")
		aCoder.encode(id, forKey: "id")
		aCoder.encode(likeCount, forKey: "like_count")
		aCoder.encode(locationID, forKey: "location_id")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(updatedAt, forKey: "updated_at")
		aCoder.encode(username, forKey: "username")
	}
}

class CurrentSpotifyUser: NSObject, NSCoding {

    let name: String
    let username: String
    var imageURLString: String = ""
    var spotifyUserURLString: String = ""
    var spotifyUserURL: URL {
        return URL(string: spotifyUserURLString)!
    }
	var imageURL: URL {
        return URL(string: imageURLString)!
    }
	var savedTracks = [String : AnyObject]()
    
    init(json: JSON) {
        name = json["display_name"].stringValue
        username = json["id"].stringValue
        let images = json["images"].arrayValue
		imageURLString = images.isEmpty ? "" : images[0]["url"].stringValue
        let externalURLs = json["external_urls"].dictionaryValue
		spotifyUserURLString = externalURLs["spotify"]!.stringValue 
		super.init()
    }
	
    override var description: String {
        return "Name: \(name)| Username: \(username)"
    }
    
    // Extend NSCoding
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
		username = aDecoder.decodeObject(forKey: "username") as! String
		super.init()
    }
	
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(username, forKey: "username")
    }
}

