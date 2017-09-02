import Neutron
import Alamofire
import SwiftyJSON

struct SearchSpotify: TempoRequest {
	typealias SearchResults = [Song]
	typealias ResponseType = SearchResults
	
	let query: String

	let route: String = "/spotify/search/"
	
	var parameters: Parameters {
		return [
			"q": query,
			"session_code": API.sharedAPI.sessionCode
		]
	}
	
	func processData(response: JSON) throws -> SearchResults {
		guard let songs = response["items"].array?.map({ Song(responseDictionary: $0.dictionaryObject ?? [:]) }) else {
			throw NeutronError.badResponseData
		}
		
		return songs
	}
}
