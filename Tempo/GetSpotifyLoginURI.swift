//
//  GetSpotifyLoginURI.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron
import SwiftyJSON

struct GetSpotifyLoginURI: TempoRequest {
	typealias URI = String
	typealias ResponseType = URI
	let sessionCode: String?
	let route = "/spotify/sign_in_uri/"
	
	var parameters: [String : Any] {
		guard let sessionCode = sessionCode else { return [:] }
		return ["session_code": sessionCode]
	}
	
	func processData(response: JSON) throws -> URI {
		guard let uri = response["uri"].string else {
			throw NeutronError.badResponseData
		}
		
		return uri
	}
}
