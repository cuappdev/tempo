import Neutron
import Alamofire
import SwiftyJSON

struct SetCurrentUser: TempoRequest {
	typealias ResponseType = Void
	
	let fbid: String
	let fbAccessToken: String
	
	let route = "/users/authenticate/"
	
	var parameters: Parameters {
		return [
			"fbid": fbid,
			"usertoken": fbAccessToken
		]
	}
	
	func processData(response: JSON) throws {
		let user = response["user"]

		guard let code = response["session"]["code"].string, user.exists() else {
			throw NeutronError.badResponseData
		}
		
		API.sharedAPI.sessionCode = code
		User.currentUser = User(json: user)
	}
}
