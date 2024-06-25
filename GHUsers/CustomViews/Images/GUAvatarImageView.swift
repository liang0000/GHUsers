//


import UIKit

// Image for UIKit
class GUAvatarImageView: UIImageView {
	let placeholderImage = Images.avatarPlaceholder
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() { // Ensure cornerRadius is updated after layout changes
		super.layoutSubviews()
		layer.cornerRadius = frame.size.width / 2
	}
	
	private func configure() {
		layer.cornerRadius 	= frame.size.width / 2
		clipsToBounds 		= true // to have cornerRadius
		image 				= placeholderImage
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	func loadImage(fromURL url: String) {
		NetworkManager.shared.downloadImage(from: url) { uiImage in
			guard let uiImage else { return }
			DispatchQueue.main.async {
				self.image = uiImage
			}
		}
	}
}
