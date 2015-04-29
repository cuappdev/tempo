//
//  User.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {
    
    static var currentUser: User = User()
    
    var caption : String = ""
    var createdAt: String = ""
    var email: String = "temp@example.com"
    var fbid: String = ""
    var followers: [String] = []
    var followersCount: Int!
    var hipsterScore = 0
    var id: Int = 0
    var likeCount: Int!
    var locationID: String = ""
    var name: String = "Temp Name"
    var updatedAt: String!
    var username: String = "temp_username"
    
    override init() {}

    init(json: JSON) {
        self.caption = json["caption"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.email = json["email"].stringValue
        self.fbid = json["fbid"].stringValue
        if let followers = json["followers"].arrayObject! as? [String] {
            self.followers = followers
        } else {
            self.followers = []
        }
        self.followersCount = json["followers_count"].intValue
        self.hipsterScore = json["hipster_score"].intValue
        self.id = json["id"].intValue
        self.likeCount = json["like_count"].intValue
        self.locationID = json["location_id"].stringValue
        self.name = json["name"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.username = json["username"].stringValue
        super.init()
    }

    override var description: String {
        return "Name: \(name) Email: \(email) FBID: \(fbid) Username: \(username)"
    }
    
    // Extend NSCoding
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        caption = aDecoder.decodeObjectForKey("caption") as! String
        createdAt = aDecoder.decodeObjectForKey("created_at") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        fbid = aDecoder.decodeObjectForKey("fbid") as! String
        followers = aDecoder.decodeObjectForKey("followers") as! [String]
        followersCount = aDecoder.decodeObjectForKey("followers_count") as! Int
        hipsterScore = aDecoder.decodeObjectForKey("hipster_score") as! Int
        id = aDecoder.decodeObjectForKey("id") as! Int!
        likeCount = aDecoder.decodeObjectForKey("like_count") as! Int
        locationID = aDecoder.decodeObjectForKey("location_id") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        updatedAt = aDecoder.decodeObjectForKey("updated_at") as! String
        username = aDecoder.decodeObjectForKey("username") as! String
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(caption, forKey: "caption")
        aCoder.encodeObject(createdAt, forKey: "created_at")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(fbid, forKey: "fbid")
        aCoder.encodeObject(followers, forKey: "followers")
        aCoder.encodeObject(followersCount, forKey: "followers_count")
        aCoder.encodeObject(hipsterScore, forKey: "hipster_score")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(likeCount, forKey: "like_count")
        aCoder.encodeObject(locationID, forKey: "location_id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(updatedAt, forKey: "updated_at")
        aCoder.encodeObject(username, forKey: "username")
        
    }
    
}

