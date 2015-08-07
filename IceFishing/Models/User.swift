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
    var id: String = ""
    var likeCount: Int!
    var locationID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var name: String {
        set(newName) {
			let newName = newName.characters.split { $0 == " " }.map { String($0) }
            firstName = newName.first ?? ""
            lastName = newName.count > 1 ? newName.last! : ""
        }
        get {
            return "\(firstName) \(lastName)"
        }
    }
    var updatedAt: String!
    var username: String = "temp_username"
    private var profileImage: UIImage?
    
    func loadImage(completion:(UIImage -> Void)) {
        if let image = profileImage {
            completion(image)
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                [weak self] in
                if let fbid = self?.fbid {
                    if let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large") {
                        let request = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
                        let data: NSData?
                        do {
                            data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
                        } catch _ {
                            data = nil
                        }
                        
                        if let data = data {
                            self?.profileImage = UIImage(data: data)
                            if let image = self?.profileImage {
                                dispatch_async(dispatch_get_main_queue(), {
                                    completion(image)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    override init() {}
    
    init(json: JSON) {
        super.init()
        self.caption = json["caption"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.email = json["email"].stringValue
        self.fbid = json["fbid"].stringValue
        followers = json["followers"].arrayObject as? [String] ?? []
        self.followersCount = json["followers_count"].intValue
        self.hipsterScore = json["hipster_score"].intValue
        self.id = json["id"].stringValue
        self.likeCount = json["like_count"].intValue
        self.locationID = json["location_id"].stringValue
        self.name = json["name"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.username = json["username"].stringValue
        loadImage {
            self.profileImage = $0
        }
    }
    
    override var description: String {
        return "Name: \(name)| Email: \(email)| ID: \(id)| Username: \(username)| FacebookID: \(fbid)"
    }
    
    // Extend NSCoding
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        caption = aDecoder.decodeObjectForKey("caption") as! String
        createdAt = aDecoder.decodeObjectForKey("created_at") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        fbid = aDecoder.decodeObjectForKey("fbid") as! String
        followers = aDecoder.decodeObjectForKey("followers") as! [String]
        followersCount = aDecoder.decodeObjectForKey("followers_count") as! Int
        hipsterScore = aDecoder.decodeObjectForKey("hipster_score") as! Int
        id = aDecoder.decodeObjectForKey("id") as! String
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

