import Neutron
import SwiftyJSON

struct GetFeed: TempoRequest {
	typealias ResponseType = [Post]

	let route: String = "/feed"

	var parameters: [String: Any] {
		return [
			"session_code": API.sharedAPI.sessionCode
		]
	}

	func processData(response: JSON) throws -> [Post] {
		guard let posts = response["posts"].array else {
			throw NeutronError.badResponseData
		}

		print(response)

		dump(posts.map { Post(json: $0) })
		return posts.map { Post(json: $0) }
	}
}
