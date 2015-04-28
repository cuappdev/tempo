//
//  API.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// TODO: Fetch userID from User object
let userID = 8

enum Router: URLStringConvertible {
    static let baseURLString = "http://icefishing-web.herokuapp.com"
    case Root
    case ValidUsername
    case Sessions
    case Users
    case Feed
    case FeedEveryone
    case History
    case Likes
    case Followings
    case Posts
    
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            case .ValidUsername:
                return "/users/valid_username"
            case .Sessions:
                return "/sessions"
            case .Users:
                return "/users/\(userID)"
            case .Feed:
                return "/\(userID)/feed"
            case .FeedEveryone:
                return "/feed"
            case .History:
                return "/\(userID)/posts"
            case .Likes:
                return "/likes"
            case .Followings:
                return "/followings"
            case .Posts:
                return "/posts"
            }
            }()
        return Router.baseURLString + path
    }
}

class API {
    
    static let sharedAPI: API = API()
    
    // Could call getSession()
    var sessionCode: String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("SessionCode") as? String
    }
    
    func userNameIsValid(username: String, completion: Bool -> Void) {
        let map: [String : Bool] -> Bool? = { $0["is_valid"] }
        get(.ValidUsername, params: ["username" : username], map: map, completion: completion)
    }
    
    func getSession(completion: User -> Void) {
        let user = [
            "email": "ldd49@cornell.edu",
            "name": "Lucas Derraugh",
            "username": "ldd49",
            "fbid": "1"
        ]
        let map: [String : User] -> User? = { $0["is_valid"] }
        post(.Sessions, params: ["user" : user], map: map, completion: completion)
    }
    
    // TODO: Change completion handles to match proper objects
    
    func fetchUser(userID: Int, completion: User -> Void) {
        let map: [String : User] -> User? = { $0["is_valid"] }
        get(.Users, params: ["user_id" : userID, "session_code" : sessionCode!], map: map, completion: completion)
    }
    
    func fetchFeed(userID: Int, completion: [Post] -> Void) {
        let map: [String : [Post]] -> [Post]? = { $0["is_valid"] }
        get(.Feed, params: ["user_id" : userID, "session_code" : sessionCode!], map: map, completion: completion)
    }
    
    func fetchFeedOfEveryone(completion: [Post] -> Void) {
        let map: [String : [Post]] -> [Post]? = { $0["is_valid"] }
        get(.FeedEveryone, params: ["session_code" : sessionCode!], map: map, completion: completion)
    }
    
    func fetchPosts(userID: Int, completion: [Post] -> Void) {
        let map: [String : [Post]] -> [Post]? = { $0["is_valid"] }
        get(.History, params: ["id" : userID, "session_code" : sessionCode!], map: map, completion: completion)
    }
    
    func updateLikes(postID: Int, unlike: Bool, completion: [String : Bool] -> Void) {
        post(.Likes, params: ["post_id" : postID, "unlike" : unlike, "session_code" : sessionCode!], map: { $0 }, completion: completion)
    }
    
    func updateFollowings(userID: Int, unfollow: Bool, completion: [String : Bool] -> Void) {
        post(.Followings, params: ["user_id" : userID, "unfollow" : unfollow, "session_code" : sessionCode!], map: { $0 }, completion: completion)
    }
    
    func updatePost(userID: Int, spotifyURL: String, completion: [String : AnyObject] -> Void) {
        post(.Posts, params: ["user_id" : userID, "spotify_url" : spotifyURL, "session_code" : sessionCode!], map: { $0 }, completion: completion)
    }
    
    // MARK: Private Methods
    
    private func post<O, T>(router: Router, params: [String : AnyObject], map: O -> T?, completion: T -> Void) {
        makeNetworkRequest(.POST, router: router, params: params, map: map, completion: completion)
    }
    
    private func get<O, T>(router: Router, params: [String : AnyObject], map: O -> T?, completion: T -> Void) {
        makeNetworkRequest(.GET, router: router, params: params, map: map, completion: completion)
    }
    
    private func makeNetworkRequest<O, T>(method: Alamofire.Method, router: Router, params: [String : AnyObject], map: O -> T?, completion: T -> Void) {
        Alamofire
            .request(method, router, parameters: params)
            .responseJSON { (request, response, json, error) -> Void in
                if let json = json as? O, obj = map(json) {
                    completion(obj)
                } else {
                    println("Couldn't decompose object")
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                }
        }
    }
}