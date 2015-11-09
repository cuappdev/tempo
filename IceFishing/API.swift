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

private enum Router: URLStringConvertible {
	static let baseURLString = "http://icefishing-web.herokuapp.com"
	case Root
	case ValidUsername
	case ValidFBID
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
	
	var URLString: String {
		let path: String = {
			switch self {
			case .Root:
				return "/"
			case .ValidUsername:
				return "/users/valid_username"
			case .ValidFBID:
				return "/users/valid_fbid"
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
			}
			}()
		return Router.baseURLString + path
	}
}

private let sessionCodeKey = "SessionCodeKey"

class API {
	
	static let sharedAPI: API = API()
	
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
		get(.ValidUsername, params: ["username": username], map: map, completion: completion)
	}
	
	func fbIdIsValid(fbid: String, completion: Bool -> Void) {
		let map: [String: Bool] -> Bool? = { $0["is_valid"] }
		get(.ValidFBID, params: ["fbid": fbid], map: map, completion: completion)
	}
	
	func getCurrentUser(username: String, completion: User -> Void) {
		let map: [String: AnyObject] -> User? = {
			if let user = $0["user"] as? [String: AnyObject], code = $0["session"]?["code"] as? String {
				self.sessionCode = code
				User.currentUser = User(json: JSON(user))
				return User.currentUser
			}
			return nil
		}
		
		let userRequest = FBRequest.requestForMe()
		userRequest.startWithCompletionHandler { [unowned self] (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
			if error == nil {
				let user = [
					"email": result["email"] as! String,
					"name": result["name"] as! String,
					"username": username,
					"fbid": result["id"] as! String
				]
				self.post(.Sessions, params: ["user": user], map: map, completion: completion)
			}
		}
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
		guard let id = Int(userID) else { return }
		post(.Followings, params: ["followed_id": id, "unfollow": unfollow, "session_code": sessionCode], map: { $0 }, completion: completion)
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
			.responseJSON { request, response, result in
				if let json = result.value as? O {
					if let obj = map(json) {
						completion?(obj)
						print(json)
					}
				} else {
					print("—————— Couldn't decompose object ——————")
					print("JSON: \(result.value)")
					print("Error: \(result.error)")
					print("Request: \(request)")
					print("Response: \(response)")
				}
		}
	}
}