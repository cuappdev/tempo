import Neutron
import SwiftyJSON
import Alamofire

struct CreatePost: TempoRequest {
	typealias ResponseType = Void

	let song: Song
	
	let route = "/posts/"
	let method: HTTPMethod = .post
	
	var parameters: [String: Any] {
		let songInfo = [
			"artist": song.artist,
			"track": song.title,
			"spotify_url": song.spotifyID
		]
		
		return [
			"session_code": API.sharedAPI.sessionCode,
			"song_info": songInfo
		]
	}
	
	func processData(response: JSON) throws {
		guard response["song"].exists() else {
			throw NeutronError.badResponseData
		}
	}
}
