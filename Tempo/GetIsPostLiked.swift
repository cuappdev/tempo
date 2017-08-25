//
//  GetIsPostLiked.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON

struct GetIsPostLiked: TempoRequest {
	typealias IsPostLiked = Bool
	typealias ResponseType = IsPostLiked
	
	let sessionCode: String
	let postId: Int
	
	let route = "/likes/is_liked/"
	
	var parameters: [String: Any] {
		return [
			"session_code": sessionCode,
			"post_id": postId
		]
	}
	
	func processData(response: JSON) throws -> IsPostLiked {
		guard let isLiked = response["is_liked"].bool else {
			throw NeutronError.badResponseData
		}
		
		return isLiked
	}
}
