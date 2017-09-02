import Neutron
import SwiftyJSON

struct GetSpotifyLoginURI: TempoRequest {
	typealias URI = String
	typealias ResponseType = URI

	let route = "/spotify/sign_in_uri/"
	
	let parameters: [String: Any] = ["session_code": API.sharedAPI.sessionCode]
	
	func processData(response: JSON) throws -> URI {
		guard let uri = response["uri"].string else {
			throw NeutronError.badResponseData
		}
		
		return uri
	}
}
