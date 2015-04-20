//
//  API.swift
//

import Foundation
import Alamofire

typealias ResponseHandler = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void
typealias ProgressHandler = (Int64, Int64, Int64) -> Void

enum Router: URLStringConvertible {
    static let baseURLString = "http://localhost:3000"
    case Root
    case FeedEveryone
    case Sessions
    
    var URLString: String {
        let path: String = {
            switch self {
            case .Root:
                return "/"
            case .FeedEveryone:
                return "/feed"
            case .Sessions:
                return "/feed"
            }
            }()
        return Router.baseURLString + path
    }
}

class API {
	
    class var sharedAPI : API {
        struct Static {
            static var instance: API = API()
        }
        return Static.instance
    }

	func isAuthorized() -> Bool {
        let sessionCode = NSUserDefaults.standardUserDefaults().objectForKey("SessionCode") as! String?
		if sessionCode == nil { return false }
		else if count(sessionCode! as String) < 1 { return false }
		return true
	}
	
}