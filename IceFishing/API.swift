//
//  API.swift
//

import Foundation

typealias ResponseHandler = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void
typealias ProgressHandler = (Int64, Int64, Int64) -> Void
enum Endpoint:String {
	
}

private var _SharedAPI: API? = nil

class API {
	let BASE_URL: String = "http://localhost:3000"
	
	class var sharedAPI: API {
		if _SharedAPI == nil {
			_sharedAPI = API()
		}
		return _SharedAPI!
	}

	func isAuthorized() -> Bool {
		let sessionCode = Defaults.get("SessionCode")
		if sessionCode == nil { return false }
		if countElements(sessionCode! as String) < 1 { return false }
		return true
	}
	
	func get(endpoint: Endpoint, responseHandler: ResponseHandler) {
		makeRequest(.GET, url: fullURL(endpoint), parameters: [String: String](), responseHandler: responseHandler)
	}
	func get(endpoint: String, responseHandler: ResponseHandler) {
		makeRequest(.GET, url: fullURL(endpoint), parameters: [String: String](), responseHandler: responseHandler)
	}
	func get(endpoint: Endpoint, params: Dictionary<String, String>, responseHandler: ResponseHandler) {
		makeRequest(.GET, url: fullURL(endpoint), parameters: params, responseHandler: responseHandler)
	}
	func get(endpoint: String, params: [String: String], responseHandler: ResponseHandler) {
		makeRequest(.GET, url: fullURL(endpoint), parameters: params, responseHandler: responseHandler)
	}
	
	func send(endpoint: Endpoint, params: Dictionary<String, AnyObject>, responseHandler: ResponseHandler) {
		send(endpoint.rawValue, params: params, responseHandler: responseHandler)
	}
	func send(endpoint: String, params: [String: AnyObject], responseHandler: ResponseHandler) {
		makeRequest(.POST, url: fullURL(endpoint), parameters: params, responseHandler: responseHandler)
	}
	
	private func fullURL(endpoint: Endpoint) -> String {
		return BASE_URL + endpoint.rawValue
	}
	private func fullURL(endpoint: String) -> String {
		return BASE_URL + endpoint
	}
	private func queryString(params: [String: AnyObject]) -> String {
		var queryString = ""
		for (param, value) in params {
			queryString += "\(param)=\(value)&"
		}
		queryString = queryString.substringToIndex(advance(queryString.startIndex, countElements(queryString) - 1))
		return "?\(queryString)"
	}
	private func fullURLWithGETParams(endpoint: Endpoint, params: [String: AnyObject]) -> String {
		let endpoint = fullURL(endpoint)
		let qstring = queryString(params)
		return "\(endpoint)\(qstring)"
	}
	private func makeRequest(method: Method, url: String, parameters: Dictionary<String, AnyObject>, responseHandler: ResponseHandler) {
		var prms = parameters
		if let sessionCode = Defaults.get("SessionCode") {
			prms["session_code"] = sessionCode
		}
		prms["build"] = UpdateCheck.buildTime()
		request(method, url, parameters: prms).responseJSON(responseHandler)
	}
}