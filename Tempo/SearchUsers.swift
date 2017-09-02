import Neutron
import SwiftyJSON

struct SearchUsers: TempoRequest {
	typealias ResponseType = [User]
	
	let query: String
	let sessionCode: String
	
	let route = "/users/search/"
	
	var parameters: [String : Any] {
		return [
			"q": query,
			"session_code": sessionCode
		]
	}
	
	func processData(response: JSON) throws -> [User] {
		guard let users = response["users"].array?.map({ User(json: $0) }) else {
			throw NeutronError.badResponseData
		}
		
		return users
	}
}
