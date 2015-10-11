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
	
	var caption = ""
	var createdAt = ""
	var email = "temp@example.com"
	var fbid = ""
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
	private var profileImage: UIImage?
	private var fbImageURL: NSURL {
		return NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
	}
	
	func loadImage(completion:(UIImage -> Void)) {
		if let image = profileImage {
			completion(image)
		} else {
			let request = NSURLRequest(URL: self.fbImageURL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
			
			NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, _ in
				self.profileImage = UIImage(data: data!)
				if let image = self.profileImage {
					dispatch_async(dispatch_get_main_queue()) {
						completion(image)
					}
				}
			}.resume()
			
		}
	}
	
	override init() {} 
	
	init(json: JSON) {
		super.init()
		caption = json["caption"].stringValue
		createdAt = json["created_at"].stringValue
		email = json["email"].stringValue
		fbid = json["fbid"].stringValue
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

