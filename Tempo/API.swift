//
//  API.swift
//  Tempo
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKShareKit

private enum Router: URLStringConvertible {
	static let baseURLString = "https://icefishing-web.herokuapp.com"
	case Root
	case ValidAuthenticate
	case ValidUsername
	case Sessions
	case UserSearch
	case Users(String)
	case Followers(String)
	case Following(String)
	case Feed(String)
	case FeedEveryone
	case History(String)
	case Likes(String?)
	case Followings
	case Posts
	case FollowSuggestions
    case SpotifyAccessToken
	
	var URLString: String {
		let path: String = {
			switch self {
			case .Root:
				return "/"
			case .ValidAuthenticate:
				return "/users/authenticate"
			case .ValidUsername:
				return "/users/valid_username"
			case .Sessions:
				return "/sessions"
			case .UserSearch:
				return "/users.json"
			case .Users(let userID):
				return "/users/\(userID)"
			case .Followers(let userID):
				return "/users/\(userID)/followers"
			case .Following(let userID):
				return "/users/\(userID)/following"
			case .Feed(let userID):
				return "/\(userID)/feed"
			case .FeedEveryone:
				return "/feed.json"
			case .History(let userID):
				return "/users/\(userID)/posts"
			case .Likes(let userID):
				if userID != nil {
					return "/users/\(userID!)/likes"
				}
				return "/likes"
			case .Followings:
				return "/followings"
			case .Posts:
				return "/posts"
			case .FollowSuggestions:
				return "/users/suggestions"
            case .SpotifyAccessToken:
                return "/spotify/get_access_token"
			}
			}()
		return Router.baseURLString + path
	}
}

private let sessionCodeKey = "SessionCodeKey"

class API {
	
	static let sharedAPI = API()
	var isAPIConnected = true
	var isConnected = true

	// Mappings
	private let postMapping: [String: [AnyObject]] -> [Post]? = {
		$0["posts"]?.map { Post(json: JSON($0)) }
	}
	
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
		post(.ValidUsername, params: ["username": username, "session_code": sessionCode], map: map, completion: completion)
	}
	
	func fbAuthenticate(fbid: String, userToken: String, completion: (success: Bool, newUser: Bool) -> Void) {
		let map: [String: AnyObject] -> (success: Bool, newUser: Bool) = {
			if let user = $0["user"] as? [String: AnyObject], code = $0["session"]?["code"] as? String {
				if let success = $0["success"] as? Bool where success == true {
					guard let newUser = $0["new_user"] as? Bool else { return (false, false) }
					self.sessionCode = code
					User.currentUser = User(json: JSON(user))
					return (success, newUser)
				}
			}
			
			return (false, false)
		}
		
		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
		userRequest.startWithCompletionHandler { connection, result, error in
			if error != nil { return }
			
			let user = [
				"email": result["email"] as? String ?? "",
				"name": result["name"] as? String ?? "",
				"fbid": result["id"] as? String ?? "",
				"usertoken": userToken
			]

			self.post(.ValidAuthenticate, params: ["user": user], map: map, completion: completion)
		}
	}
	
	func setCurrentUser(fbid: String, fbAccessToken: String, completion: Bool -> Void) {
		let user = ["fbid": fbid, "usertoken": fbAccessToken]
		let map: [String: AnyObject] -> Bool = {
			guard let user = $0["user"] as? [String: AnyObject], code = $0["session"]?["code"] as? String else { return false }
			self.sessionCode = code
			User.currentUser = User(json: JSON(user))
			return true
		}
		self.post(.Sessions, params: ["user": user], map: map, completion: completion)
	}
	
	func updateCurrentUser(changedUsername: String, didSucceed: Bool -> Void) {
		let map: [String: Bool] -> Bool? = {
			guard let success = $0["success"] where success != false else { return false }
			User.currentUser.username = changedUsername
			return true
		}
		let changes = ["username": changedUsername]
		patch(.Users(User.currentUser.id), params: ["user": changes, "session_code": sessionCode], map: map, completion: didSucceed)
	}
	
	func searchUsers(username: String, completion: [User] -> Void) {
		let map: [String: [AnyObject]] -> [User]? = {
			$0["users"]?.map { User(json: JSON($0)) }
		}
		get(.UserSearch, params: ["q": username, "session_code": sessionCode], map: map, completion: completion)
	}
	
	func fetchUser(userID: String, completion: User -> Void) {
		let map: [String: AnyObject] -> User? = { User(json: JSON($0)) }
		get(.Users(userID), params: ["session_code": sessionCode], map: map, completion: completion)
	}
	
	func fetchFollowers(userID: String, completion: [User] -> Void) {
		let map: [String: AnyObject] -> [User]? = {
			guard let followers = $0["followers"] as? [[String: AnyObject]] else { return nil }
			return followers.map { User(json: JSON($0)) }
		}
		get(.Followers(userID), params: ["session_code": sessionCode], map: map, completion: completion)
	}
	
	func fetchFollowing(userID: String, completion: [User] -> Void) {
		let map: [String: AnyObject] -> [User]? = {
			guard let following = $0["following"] as? [[String: AnyObject]] else { return nil }
			return following.map { User(json: JSON($0)) }
		}
		get(.Following(userID), params: ["session_code": sessionCode], map: map, completion: completion)
	}
	
	func fetchFollowSuggestions(completion: [User] -> Void, length: Int, page: Int) {
		let map: [String: AnyObject] -> [User]? = {
			guard let users = $0["users"] as? [AnyObject] else { return [] }
			return users.map { User(json: JSON($0)) }
		}
		post(.FollowSuggestions, params: ["p": page, "l": length, "session_code": sessionCode], map: map, completion: completion)
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
	
	func updateLikes(postID: String, unlike: Bool, completion: ([String: Bool] -> Void)? = nil) {
		post(.Likes(nil), params: ["post_id": postID, "unlike": unlike, "session_code": sessionCode], map: { $0 }, completion: completion)
	}
	
	func fetchLikes(userID: String, completion: [Song] -> Void) {
		let map: [String: [AnyObject]] -> [Song]? = {
			let songIDs: [String] = $0["songs"]?.flatMap { $0["spotify_url"] as? String } ?? []
			return songIDs.map { Song(songID: $0) }
		}
		get(.Likes(userID), params: ["session_code": sessionCode], map: map, completion: completion)
	}
	
	func updateFollowings(userID: String, unfollow: Bool, completion: ([String: Bool] -> Void)? = nil) {
		post(.Followings, params: ["followed_id": userID, "unfollow": unfollow, "session_code": sessionCode], map: { $0 as [String: Bool] }, completion: completion)
	}
	
	func updatePost(userID: String, song: Song, completion: [String: AnyObject] -> Void) {
		let songDict = [
			"artist": song.artist,
			"track": song.title,
			"spotify_url": song.spotifyID
		]
		let map: [String: AnyObject] -> [String: AnyObject]? = { $0 }
		post(.Posts, params: ["user_id": userID, "song": songDict, "session_code": sessionCode], map: map, completion: completion)
	}
    
    func getSpotifyAccessToken(completion: (Bool, String, Double) -> Void) {
        let map: [String: AnyObject] -> (Bool, String, Double)? = {
            let expiresAt = $0["expires_at"] as? Double ?? 0.0
            
			if let success = $0["success"] as? Bool where success == true {
                let accessToken = $0["access_token"] as? String ?? ""
                return (success, accessToken, expiresAt)
            } else {
                let url = $0["url"] as? String ?? ""
                return (false, url, expiresAt)
            }
        }
        get(.SpotifyAccessToken, params: ["session_code": sessionCode], map: map, completion: completion)
    }
	
	// MARK: - Private Methods
	
	private func post<O, T>(router: Router, params: [String: AnyObject], map: O -> T?, completion: (T -> Void)?) {
		makeNetworkRequest(.POST, router: router, params: params, map: map, completion: completion)
	}
	
	private func get<O, T>(router: Router, params: [String: AnyObject], map: O -> T?, completion: (T -> Void)?) {
		makeNetworkRequest(.GET, router: router, params: params, map: map, completion: completion)
	}
	
	private func patch<O, T>(router: Router, params: [String: AnyObject], map: O -> T?, completion: (T -> Void)?) {
		makeNetworkRequest(.PATCH, router: router, params: params, map: map, completion: completion)
	}
	
	private func makeNetworkRequest<O, T>(method: Alamofire.Method, router: Router, params: [String: AnyObject], map: O -> T?, completion: (T -> Void)?) {
		Alamofire
			.request(method, router, parameters: params)
			.responseJSON { response in
				if let json = response.result.value as? O {
					if let obj = map(json) {
						completion?(obj)
						self.isConnected = true
						self.isAPIConnected = true
					} else {
						print(json)
					}
				} else if let error = response.result.error {
					print(error)
					if error.code != -1009 {
						self.isAPIConnected = false
						self.isConnected = true
						
					} else {
						self.isConnected = false
						self.isAPIConnected = true
					}
				}
		}
	}
}