//
//  GetSpotifyLoginURI.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON

struct GetSpotifyLoginURIResponse {
	var uri: String
}

struct GetSpotifyLoginURI: TempoRequest {
	typealias ResponseType = GetSpotifyLoginURIResponse
	let sessionCode: String?
	let route = "/spotify/sign_in_uri/"
	
	var parameters: [String : Any] {
		guard let sessionCode = sessionCode else { return [:] }
		return ["session_code": sessionCode]
	}
	
	func process(response: JSON) throws -> GetSpotifyLoginURIResponse {
		guard let success = response["success"].bool,
			success,
			let uri = response["data"]["uri"].string else {
				throw NeutronError.badResponseData
		}
		
		return GetSpotifyLoginURIResponse(uri: uri)
	}
}
