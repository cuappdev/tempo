//
//  User.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
    
    static let currentUser: User = User()
    
    var caption : String = ""
    var createdAt: String = ""
    var email: String = "temp@example.com"
    var fbid: String = ""
    var followers: [String] = []
    var followersCount: Int!
    var hipsterScore = 0
    var id: String = ""
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
        self.id = json["id"].stringValue
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
    
    /*required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        id = aDecoder.decodeObjectForKey("id") as! String
        username = aDecoder.decodeObjectForKey("username") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(followers, forKey: "followers")
        aCoder.encodeObject(following, forKey: "following")
    }*/
    
}

