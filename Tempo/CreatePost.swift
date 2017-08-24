//
//  CreatePost.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/24/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON
import Alamofire

struct CreatePostResponse {
	let song: [String: Any]
}

struct CreatePost: TempoRequest {
	typealias ResponseType = CreatePostResponse
	
	// Parameters
	let sessionCode: String?
	let songInfo: [String: Any]?
	
	// POST to posts endpoint
	let route = "/posts/"
	let method = HTTPMethod.post
	
	var parameters: [String: Any] {
		guard let sessionCode = sessionCode,
			let songInfo = songInfo else { return [:] }
		return [
			"session_code": sessionCode,
			"song_info": songInfo
		]
	}
	
	func process(response: JSON) throws -> CreatePostResponse {
		guard let success = response["success"].bool,
			success,
			let song = response["data"]["song"].dictionaryObject else {
				throw NeutronError.badResponseData
		}
		return CreatePostResponse(song: song)
	}
}
