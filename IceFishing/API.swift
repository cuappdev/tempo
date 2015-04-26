//
//  API.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation
import Alamofire

//typealias ResponseHandler = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void
//typealias ProgressHandler = (Int64, Int64, Int64) -> Void

enum Router: URLStringConvertible {
    static let baseURLString = "http://icefishing-web.herokuapp.com"
    case Root
    case ValidUsername
    case FeedEveryone
    case Sessions
    
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            case .ValidUsername:
                return "/users/valid_username"
            case .FeedEveryone:
                return "/feed"
            case .Sessions:
                return "/sessions"
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
    
    func userNameIsValid(name: String, completion: Bool -> Void) {
        Alamofire
            .request(.GET, Router.ValidUsername, parameters: ["username" : name])
            .responseJSON { (_, _, json, _) -> Void in
                if let json = json as? [String : Bool], isValid = json["is_valid"] {
                    completion(isValid)
                } else {
                    completion(false)
                }
        }
    }
    
    func getSession() {
        let user = [
            "email": "ldd49@cornell.edu",
            "name": "Lucas Derraugh",
            "username": "ldd49",
            "fbid": "1"
        ]
        Alamofire
            .request(.POST, Router.Sessions, parameters: ["user" : user], encoding: .JSON)
            .responseJSON { (request, response, data, error) -> Void in
                println(response)
                println(data)
                println(error)
        }
    }
    
    // TODO: Change completion handles to match proper objects
    
    func fetchFeed(userID: Int, completion: Bool -> Void) {
        // TODO
    }
    
    func fetchPosts(userID: Int, completion: Bool -> Void) {
        // TODO
    }
    
    func fetchFollowing(userID: Int, completion: Bool -> Void) {
        // TODO
    }
    
    func fetchFollowers(userID: Int, completion: Bool -> Void) {
        // TODO
    }
    
}