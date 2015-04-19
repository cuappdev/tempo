//
//  User.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    var name: String = ""
    var email: String = ""
    var id: String = ""
    var friends: [String] = []
    var profilePicture: UIImage!
    var username: String = ""
    
    init(name: String, email: String, id: String, friends: [String], profilePicture: UIImage!, username: String) {
        self.name = name
        self.email = email
        self.id = id
        self.friends = friends
        self.profilePicture = profilePicture
        self.username = username
    }
    
    override var description: String {
        return "Name: \(name) Email: \(email) ID: \(id) Friends: \(friends) Username: \(username)"
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as String
        email = aDecoder.decodeObjectForKey("email") as String
        id = aDecoder.decodeObjectForKey("id") as String
        friends = aDecoder.decodeObjectForKey("friends") as [String]
        profilePicture = aDecoder.decodeObjectForKey("profilePicture") as UIImage!
        username = aDecoder.decodeObjectForKey("username") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(friends, forKey: "friends")
        aCoder.encodeObject(profilePicture, forKey: "profilePicture")
        aCoder.encodeObject(username, forKey: "username")
    }
    
}

