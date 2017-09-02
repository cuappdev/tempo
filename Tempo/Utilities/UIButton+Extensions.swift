import UIKit

extension UIButton {
	override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let relativeFrame = self.bounds
		let hitTestEdgeInsets = (self.tag == 0) ? UIEdgeInsetsMake(0, 0, 0, 0) : UIEdgeInsetsMake(-20, -20, -20, -20)
		let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
		return hitFrame.contains(point)
	}
}
