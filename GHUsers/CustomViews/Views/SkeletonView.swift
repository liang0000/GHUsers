//


import UIKit

class SkeletonView: UIView {
	private let gradientLayer = CAGradientLayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = bounds
	}
	
	private func configure() {
		gradientLayer.colors = [
			UIColor(white: 0.85, alpha: 1.0).cgColor,
			UIColor(white: 0.75, alpha: 1.0).cgColor,
			UIColor(white: 0.85, alpha: 1.0).cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		gradientLayer.locations = [0, 0.5, 1]
		layer.addSublayer(gradientLayer)
		translatesAutoresizingMaskIntoConstraints = false
		startAnimating()
	}
	
	private func startAnimating() {
		let animation = CABasicAnimation(keyPath: "locations")
		animation.fromValue = [0, 0.1, 0.2]
		animation.toValue = [0.8, 0.9, 1]
		animation.duration = 1.0
		animation.repeatCount = .infinity
		gradientLayer.add(animation, forKey: "skeletonAnimation")
	}
}
