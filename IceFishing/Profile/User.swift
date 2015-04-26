//
//  User.swift
//  Profile
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    // Singleton class for sharing between view controllers
    class var sharedInstance : User {
        struct Static {
            static let instance : User = User(name: "Annie", email: "ac962@cornell.edu", id: "10205298251448857", username: "anniec311")
        }
        return Static.instance
    }
    
    var name: String = ""
    var email: String = ""
    var id: String = ""
    var username: String = ""
    
    init(name: String, email: String, id: String, username: String) {
        self.name = name
        self.email = email
        self.id = id
        self.username = username
    }

    override var description: String {
        return "Name: \(name) Email: \(email) ID: \(id) Username: \(username)"
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
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
    }
    
}

