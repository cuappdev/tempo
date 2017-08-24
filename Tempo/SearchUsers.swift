//
//  SearchUsers.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON

struct SearchUsersResponse {
	var users: [User]
}

struct SearchUsers: TempoRequest {
	typealias ResponseType = SearchUsersResponse
	let q: String?
	let sessionCode: String?
	let route = "/users/search/"
	
	var parameters: [String : Any] {
		guard let q = q, let sessionCode = sessionCode else { return [:] }
		return [
			"q": q,
			"session_code": sessionCode
		]
	}
	
	func process(response: JSON) throws -> SearchUsersResponse {
		guard let success = response["success"].bool,
			success,
			let userJSONs = response["data"]["users"].array else {
				throw NeutronError.badResponseData
		}
		
		let users = userJSONs.map { User(json: $0) }
		return SearchUsersResponse(users: users)
	}
}
