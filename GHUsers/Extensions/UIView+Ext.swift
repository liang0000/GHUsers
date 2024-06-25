//


import UIKit

extension UIView {
	func addSubviews(_ views: UIView...) { // variadic parameter
		for view in views { addSubview(view) }
	}
}
