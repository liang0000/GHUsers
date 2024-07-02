//


import UIKit

enum LabelType {
	case primary, secondary
}

class GULabel: UILabel {
	let skeletonView = SkeletonView(frame: .zero)
	
	override init(frame: CGRect) { // designated initialiser
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(labelType: LabelType, fontSize: CGFloat) { // has to call at least one designated initialiser
		self.init(frame: .zero) // will call designated initialiser
		font 		= UIFont.systemFont(ofSize: fontSize, weight: labelType == .primary ? .bold : .medium)
		textColor 	= labelType == .primary ? .label : .secondaryLabel
	}
	
	private func configure() {
		adjustsFontSizeToFitWidth 	= true
		minimumScaleFactor 			= 0.9 // to set min 90%
		lineBreakMode 				= .byTruncatingTail // to make text like tit...
		translatesAutoresizingMaskIntoConstraints = false
		showSkeleton()
	}
	
	private func showSkeleton() {
		addSubview(skeletonView)
		NSLayoutConstraint.activate([
			skeletonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			skeletonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			skeletonView.topAnchor.constraint(equalTo: topAnchor),
			skeletonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	private func hideSkeleton() {
		skeletonView.removeFromSuperview()
	}
	
	func setText(_ text: String?) {
		self.text = text ?? ""
		hideSkeleton()
	}
}
