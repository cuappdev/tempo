import Neutron
import SwiftyJSON

struct GetIsPostLiked: TempoRequest {
	typealias IsPostLiked = Bool
	typealias ResponseType = IsPostLiked
	
	let postId: Int
	
	let route = "/likes/is_liked/"
	
	var parameters: [String: Any] {
		return [
			"session_code": API.sharedAPI.sessionCode,
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
