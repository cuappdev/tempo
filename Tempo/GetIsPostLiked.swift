//
//  GetIsPostLiked.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON

struct GetIsPostLikedResponse {
	var isLiked: Bool
}

struct GetIsPostLiked: TempoRequest {
	typealias ResponseType = GetIsPostLikedResponse
	
	let sessionCode: String?
	let postId: Int?
	
	let route = "/likes/is_liked/"
	
	var parameters: [String: Any] {
		guard let sessionCode = sessionCode,
			let postId = postId else {
				return [:]
		}
		return [
			"session_code": sessionCode,
			"post_id": postId
		]
	}
	
	func process(response: JSON) throws -> GetIsPostLikedResponse {
		guard let success = response["success"].bool,
			success,
			let isLiked = response["data"]["is_liked"].bool else {
			throw NeutronError.badResponseData
		}
		return GetIsPostLikedResponse(isLiked: isLiked)
	}
}
