import Neutron
import SwiftyJSON
import Alamofire

struct CreatePost: TempoRequest {
	typealias Song = [String: Any]
	typealias ResponseType = Song
	
	// Parameters
	let sessionCode: String
	let songInfo: [String: Any]
	
	// POST to posts endpoint
	let route = "/posts/"
	let method = HTTPMethod.post
	
	var parameters: [String: Any] {
		return [
			"session_code": sessionCode,
			"song_info": songInfo
		]
	}
	
	func processData(response: JSON) throws -> Song {
		guard let song = response["song"].dictionaryObject else {
			throw NeutronError.badResponseData
		}
		
		return song
	}
}
