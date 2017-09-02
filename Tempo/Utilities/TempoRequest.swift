import Neutron
import SwiftyJSON

// Custom protocol with a default host and
// processData function
public protocol TempoRequest: JSONQuark {
	associatedtype ResponseType
	func processData(response: JSON) throws -> ResponseType
}

extension TempoRequest {
	var host: String {
		return "http://10.147.130.117:5000"
	}
	
	public func process(response: JSON) throws -> ResponseType {
		guard let success = response["success"].bool else {
			throw NeutronError.badResponseData
		}
		
		guard success else {
			let errors = response["data"]["errors"].arrayValue.map({ $0.stringValue })
			throw TempoError.backendError(errors: errors)
		}
		
		return try processData(response: response["data"])
	}
}

public enum TempoError: Error {
	case backendError(errors: [String])
	
	var localizedDescription: String {
		switch self {
		case .backendError(let errors):
			return "Something went wrong: \(errors)"
		}
	}
}
