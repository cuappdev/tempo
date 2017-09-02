import Neutron
import SwiftyJSON

struct IsUsernameValid: TempoRequest {
	typealias ResponseType = Bool

	let route = "/users/valid_username"

	let parameters: [String: Any] = ["session_code": API.sharedAPI.sessionCode]

	func processData(response: JSON) throws -> Bool {
		guard let isValid = response["is_valid"].bool else {
			throw NeutronError.badResponseData
		}

		return isValid
	}
}
