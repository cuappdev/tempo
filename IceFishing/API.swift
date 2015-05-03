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

enum Router: URLStringConvertible {
    static let baseURLString = "http://icefishing-web.herokuapp.com"
    case Root
    case ValidUsername
    case Sessions
    case Users(String)
    case Feed(String)
    case FeedEveryone
    case History(String)
    case Likes(String?)
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
            case .Users(let userID):
                return "/users/\(userID)"
            case .Feed(let userID):
                return "/\(userID)/feed"
            case .FeedEveryone:
                return "/feed"
            case .History(let userID):
                return "/\(userID)/posts"
            case .Likes(let userID):
                if (userID != nil) {
                    return "/\(userID!)/likes"
                }
                return "/lieks"
            case .Followings:
                return "/followings"
            case .Posts:
                return "/posts"
            }
            }()
        return Router.baseURLString + path
    }
}

private let currentUserKey = "CurrentUserKey"
private let sessionCodeKey = "SessionCodeKey"

class API {
    
    static let sharedAPI: API = API()
    
    // Mappings
    let postMapping: [String: [AnyObject]] -> [Post]? = {
        if let posts = $0["posts"] {
            var feed: [Post] = []
            for post in posts {
                feed.append(Post(json: JSON(post)))
            }
            return feed.reverse()
        }
        return nil
    }
    
    let songMapping: [String: [AnyObject]] -> [Song]? = {
        var songs: [Song] = []
        
        println($0)
        
        return songs
    }
    
    // Could call getSession()
    private var sessionCode: String {
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: sessionCodeKey)
        }
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(sessionCodeKey) as? String ?? ""
        }
    }
    
    func usernameIsValid(username: String, completion: Bool -> Void) {
        let map: [String: Bool] -> Bool? = { $0["is_valid"] }
        get(.ValidUsername, params: ["username": username], map: map, completion: completion)
    }
    
    func getCurrentUser(completion: User -> Void) {
        let map: [String: AnyObject] -> User? = {
            if let user = $0["user"] as? [String: AnyObject], code = $0["session"]?["code"] as? String {
                self.sessionCode = code
                User.currentUser = User(json: JSON(user))
                return User.currentUser
            }
            return nil
        }
        // TODO: This call should probably be removed and in place only called by signin folks after login
        // Other times you can simply reference the saved user object, instead of pinging facebook
        let userRequest : FBRequest = FBRequest.requestForMe()
        userRequest.startWithCompletionHandler { [unowned self] (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            println(result)
            if (error == nil) {
                let user = [
                    "email": result["email"] as! String,
                    "name": result["name"] as! String,
                    "username": result["name"] as! String,
                    "fbid": result["id"] as! String
                ]
                self.post(.Sessions, params: ["user": user], map: map, completion: completion)
            }
        }
    }
    
    func fetchUser(userID: String, completion: User -> Void) {
        let map: [String: AnyObject] -> User? = { User(json: JSON($0)) }
        get(.Users(userID), params: ["session_code": sessionCode], map: map, completion: completion)
    }
    
    func fetchFeed(userID: String, completion: [Post] -> Void) {
        get(.Feed(userID), params: ["session_code": sessionCode], map: postMapping, completion: completion)
    }
    
    // Method used for testing purposes
    func fetchFeedOfEveryone(completion: [Post] -> Void) {
        get(.FeedEveryone, params: ["session_code": sessionCode], map: postMapping, completion: completion)
    }
    
    func fetchPosts(userID: String, completion: [Post] -> Void) {
        get(.History(userID), params: ["id": userID, "session_code": sessionCode], map: postMapping, completion: completion)
    }
    
    func updateLikes(postID: String, unlike: Bool, completion: [String: Bool] -> Void) {
        post(Router.Likes(nil), params: ["post_id": postID, "unlike": unlike, "session_code": sessionCode], map: { $0 }, completion: completion)
    }
    
    func fetchLikes(userID: String, completion: [Song] -> Void) {
        get(Router.Likes(userID), params: [:], map: songMapping, completion: completion)
    }
    
    func updateFollowings(userID: String, unfollow: Bool, completion: [String: Bool] -> Void) {
        post(.Followings, params: ["user_id": userID, "unfollow": unfollow, "session_code": sessionCode], map: { $0 }, completion: completion)
    }
    
    func updatePost(userID: String, song: Song, completion: [String: AnyObject] -> Void) {
        let songDict = [
            "artist": song.artist,
            "track": song.title,
            "spotify_url": song.spotifyID
        ]
        let map: [String: AnyObject] -> [String: AnyObject]? = { Optional($0) }
        post(.Posts, params: ["user_id": userID, "song": songDict, "session_code": sessionCode], map: map, completion: completion)
    }
    
    // MARK: Private Methods
    
    private func post<O, T>(router: Router, params: [String: AnyObject], map: O -> T?, completion: T -> Void) {
        makeNetworkRequest(.POST, router: router, params: params, map: map, completion: completion)
    }
    
    private func get<O, T>(router: Router, params: [String: AnyObject], map: O -> T?, completion: T -> Void) {
        makeNetworkRequest(.GET, router: router, params: params, map: map, completion: completion)
    }
    
    private func makeNetworkRequest<O, T>(method: Alamofire.Method, router: Router, params: [String: AnyObject], map: O -> T?, completion: T -> Void) {
        Alamofire
            .request(method, router, parameters: params)
            .responseJSON { (request, response, json, error) -> Void in
                if let json = json as? O, obj = map(json) {
                    completion(obj)
                } else {
                    println("—————— Couldn't decompose object ——————")
                    println("JSON: \(json)")
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                }
        }
    }
}