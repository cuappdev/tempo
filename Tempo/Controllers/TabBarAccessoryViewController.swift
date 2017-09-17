
import UIKit

protocol TabBarAccessoryViewControllerProtocol {
    func showAccessoryViewController(animated: Bool)
    func expandAccessoryViewController(animated: Bool)
    func collapseAccessoryViewController(animated: Bool)
    func hideAccessoryViewController(animated: Bool)
}

class TabBarAccessoryViewController: UIViewController, TabBarAccessoryViewControllerProtocol {
    
    func showAccessoryViewController(animated: Bool) {
        preconditionFailure("This method must be overridden")
    }

    func expandAccessoryViewController(animated: Bool) {
        preconditionFailure("This method must be overridden")
    }
    
    func collapseAccessoryViewController(animated: Bool) {
        preconditionFailure("This method must be overridden")
    }
    
    func hideAccessoryViewController(animated: Bool) {
        preconditionFailure("This method must be overridden")
    }
}
