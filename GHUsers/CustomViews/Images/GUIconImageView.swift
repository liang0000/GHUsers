//


import UIKit

class GUIconImageView: UIImageView {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(icon: UIImage) {
		self.init(frame: .zero)
		configure(icon: icon)
	}
	
	private func configure(icon: UIImage) {
		image = icon
		translatesAutoresizingMaskIntoConstraints = false
	}
}
