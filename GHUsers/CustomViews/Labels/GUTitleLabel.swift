//


import UIKit

class GUTitleLabel: UILabel {
	override init(frame: CGRect) { // designated initialiser
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat) { // has to call at least one designated initialiser
		self.init(frame: .zero) // will call designated initialiser
		self.textAlignment = textAlignment
		font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
	}
	
	private func configure() {
		textColor 					= .label
		adjustsFontSizeToFitWidth 	= true
		minimumScaleFactor 			= 0.9 // to set min 90%
		lineBreakMode 				= .byTruncatingTail // to make text like tit...
		translatesAutoresizingMaskIntoConstraints = false
	}
}
