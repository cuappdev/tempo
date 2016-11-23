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

private enum Router: URLConvertible {
	static let tempoBaseURLString = "https://fast-fortress-75502.herokuapp.com/"
	static let notificationsBaseURLString = "http://9144f8af.ngrok.io"
	
	case root
	case validAuthenticate
	case validUsername
	case sessions
	case userSearch
	case users(String)
	case followers(String)
	case following(String)
	case feed(String)
	case feedEveryone
	case history(String)
	case likes(String?)
	case followings
	case posts
	case followSuggestions
    case spotifyAccessToken
	case notifications(String)
	case registerNotifications
	
	func asURL() throws -> URL {
		if let url = URL(string: URLString) {
			return url
		}
		
		throw AFError.invalidURL(url: self)
	}
	
	var URLString: String {
		let path: String = {
			switch self {
			case .root:
				return "/"
			case .validAuthenticate:
				return "/users/authenticate"
			case .validUsername:
				return "/users/valid_username"
			case .sessions:
				return "/sessions"
			case .userSearch:
				return "/users.json"
			case .users(let userID):
				return "/users/\(userID)"
			case .followers(let userID):
				return "/users/\(userID)/followers"
			case .following(let userID):
				return "/users/\(userID)/following"
			case .feed(let userID):
				return "/\(userID)/feed"
			case .feedEveryone:
				return "/feed"
			case .history(let userID):
				return "/users/\(userID)/posts"
			case .likes(let userID):
				if userID != nil {
					return "/users/\(userID!)/likes"
				}
				return "/likes"
			case .followings:
				return "/followings"
			case .posts:
				return "/posts"
			case .followSuggestions:
				return "/users/suggestions"
            case .spotifyAccessToken:
                return "/spotify/get_access_token"
			case .notifications(let userID):
				return "/users/\(userID)/toggle_push"
			case .registerNotifications:
				return "/register_user"
			}
			}()
		
		switch self {
		case .registerNotifications:
			return Router.notificationsBaseURLString + path
		default:
			return Router.tempoBaseURLString + path
		}
	}
}

private let sessionCodeKey = "SessionCodeKey"

class API {
	
	static let sharedAPI = API()
	var isAPIConnected = true
	var isConnected = true

	// Mappings
	fileprivate let postMapping: ([String: [AnyObject]]) -> [Post]? = {
		$0["posts"]?.map { Post(json: JSON($0)) }
	}
	
	fileprivate var sessionCode: String {
		set {
			UserDefaults.standard.set(newValue, forKey: sessionCodeKey)
		}
		get {
			return UserDefaults.standard.object(forKey: sessionCodeKey) as? String ?? ""
		}
	}
	
	func usernameIsValid(_ username: String, completion: @escaping (Bool) -> Void) {
		let map: ([String: Bool]) -> Bool? = { $0["is_valid"] }
		post(.validUsername, params: ["username": username as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fbAuthenticate(_ fbid: String, userToken: String, completion: @escaping (_ success: Bool, _ newUser: Bool) -> Void) {
		let map: ([String: AnyObject]) -> (success: Bool, newUser: Bool) = {
			if let user = $0["user"] as? [String: AnyObject], let code = $0["session"]?["code"] as? String {
				if let success = $0["success"] as? Bool, success == true {
					guard let newUser = $0["new_user"] as? Bool else { return (false, false) }
					self.sessionCode = code
					User.currentUser = User(json: JSON(user))
					return (success, newUser)
				}
			}
			
			return (false, false)
		}
		
		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
		
		let _ = userRequest?.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
			if error != nil { return }
			
			guard let userJSON = result as? [String:Any] else {
				return
			}
			
			let email = userJSON["email"] as? String ?? ""
			let name = userJSON["name"] as? String ?? ""
			let fbid = userJSON["fbid"] as? String ?? ""
			
			let user: [String:AnyObject] = [
				"email": email as AnyObject,
				"name": name as AnyObject,
				"fbid": fbid as AnyObject,
				"usertoken": userToken as AnyObject
			]
			
			self.post(.validAuthenticate, params: ["user": user as AnyObject], map: map, completion: completion)
		}
	}
	
	func registerForRemotePushNotificationsWithDeviceToken(_ deviceToken: Data, completion: @escaping (Bool) -> Void) {
		
		if User.currentUser.id == "" { return }
		
		var token = NSString(format: "%@", deviceToken as NSData)
		token = token.replacingOccurrences(of: "<", with: "") as NSString
		token = token.replacingOccurrences(of: ">", with: "") as NSString
		token = token.replacingOccurrences(of: " ", with: "") as NSString
		
		let params = ["app": "TEMPO", "push_id":"\(token)", "user_id": User.currentUser.id]
		
		let map: ([String: AnyObject]) -> Bool? = {
			guard let success = $0["success"] as? String, success == "User successfully registered." else { return false }
			User.currentUser.remotePushNotificationsEnabled = true
			UserDefaults.standard.set(true, forKey: SettingsViewController.registeredForRemotePushNotificationsKey)
			return true
		}
		
		post(.registerNotifications, params: params as [String : AnyObject], map: map, completion: completion)
	}
	
	func toggleRemotePushNotifications(userID: String, enabled: Bool, completion: @escaping (Bool) -> Void) {
		let map: ([String: Bool]) -> Bool? = {
			guard let success = $0["success"], success != false else { return false }
			User.currentUser.remotePushNotificationsEnabled = enabled
			return true
		}
		
		put(.notifications(userID), params: ["enabled" : enabled as AnyObject], map: map, completion: completion)
	}
	
	func setCurrentUser(_ fbid: String, fbAccessToken: String, completion: @escaping (Bool) -> Void) {
		let user = ["fbid": fbid, "usertoken": fbAccessToken]
		let map: ([String: AnyObject]) -> Bool = {
			guard let user = $0["user"] as? [String: AnyObject], let code = $0["session"]?["code"] as? String else { return false }
			self.sessionCode = code
			User.currentUser = User(json: JSON(user))
			return true
		}
		self.post(.sessions, params: ["user": user as AnyObject], map: map, completion: completion)
	}
	
	func updateCurrentUser(_ changedUsername: String, didSucceed: @escaping (Bool) -> Void) {
		let map: ([String: Bool]) -> Bool? = {
			guard let success = $0["success"], success != false else { return false }
			User.currentUser.username = changedUsername
			return true
		}
		let changes = ["username": changedUsername]
		put(.users(User.currentUser.id), params: ["user": changes as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: didSucceed)
	}
	
	func searchUsers(_ username: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: [AnyObject]]) -> [User]? = {
			$0["users"]?.map { User(json: JSON($0)) }
		}
		get(.userSearch, params: ["q": username as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchUser(_ userID: String, completion: @escaping (User) -> Void) {
		let map: ([String: AnyObject]) -> User? = { User(json: JSON($0)) }
		get(.users(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowers(_ userID: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let followers = $0["followers"] as? [[String: AnyObject]] else { return nil }
			return followers.map { User(json: JSON($0)) }
		}
		get(.followers(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowing(_ userID: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let following = $0["following"] as? [[String: AnyObject]] else { return nil }
			return following.map { User(json: JSON($0)) }
		}
		get(.following(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowSuggestions(_ completion: @escaping ([User]) -> Void, length: Int, page: Int) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let users = $0["users"] as? [AnyObject] else { return [] }
			return users.map { User(json: JSON($0)) }
		}
		post(.followSuggestions, params: ["p": page as AnyObject, "l": length as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFeed(_ userID: String, completion: @escaping ([Post]) -> Void) {
		get(.feed(userID), params: ["session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	// Method used for testing purposes
	func fetchFeedOfEveryone(_ completion: @escaping ([Post]) -> Void) {
		get(.feedEveryone, params: ["session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	func fetchPosts(_ userID: String, completion: @escaping ([Post]) -> Void) {
		get(.history(userID), params: ["id": userID as AnyObject, "session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	func updateLikes(_ postID: String, unlike: Bool, completion: (([String: Bool]) -> Void)? = nil) {
		if unlike {
			delete(.likes(nil), params: ["post_id": postID as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 }, completion: completion)
		} else {
			post(.likes(nil), params: ["post_id": postID as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 }, completion: completion)
		}
	}
	
	func fetchLikes(_ userID: String, completion: @escaping ([Song]) -> Void) {
		let map: ([String: [AnyObject]]) -> [Song]? = {
			let songIDs: [String] = $0["songs"]?.flatMap { $0["spotify_url"] as? String } ?? []
			return songIDs.map { Song(songID: $0) }
		}
		get(.likes(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func updateFollowings(_ userID: String, unfollow: Bool, completion: (([String: Bool]) -> Void)? = nil) {
		if unfollow {
			delete(.followings, params: ["followed_id": userID as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 as [String: Bool] }, completion: completion)
		} else {
			post(.followings, params: ["followed_id": userID as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 as [String: Bool] }, completion: completion)
		}
	}
	
	func updatePost(_ userID: String, song: Song, completion: @escaping ([String: AnyObject]) -> Void) {
		let songDict = [
			"artist": song.artist,
			"track": song.title,
			"spotify_url": song.spotifyID
		]
		let map: ([String: AnyObject]) -> [String: AnyObject]? = { $0 }
		post(.posts, params: ["user_id": userID as AnyObject, "song": songDict as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
    
    func getSpotifyAccessToken(_ completion: @escaping (Bool, String, Double) -> Void) {
        let map: ([String: AnyObject]) -> (Bool, String, Double)? = {
            let expiresAt = $0["expires_at"] as? Double ?? 0.0
            
			if let success = $0["success"] as? Bool, success == true {
                let accessToken = $0["access_token"] as? String ?? ""
                return (success, accessToken, expiresAt)
            } else {
                let url = $0["url"] as? String ?? ""
                return (false, url, expiresAt)
            }
        }
        get(.spotifyAccessToken, params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
    }
	
	// MARK: - Private Methods
	
	fileprivate func post<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.post, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func get<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.get, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func delete<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.delete, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func put<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.put, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func makeNetworkRequest<O, T>(_ method: Alamofire.HTTPMethod, router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		
		let encoding: ParameterEncoding = method == .get || method == .delete ? URLEncoding.default : JSONEncoding.default
		Alamofire.request(router, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON(completionHandler: { response in

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
//					TODO
//					if error.code != -1009 {
//						self.isAPIConnected = false
//						self.isConnected = true
//						
//					} else {
//						self.isAPIConnected = true
//						self.isConnected = false
//					}
				}
		})
	}
}
