//


import UIKit

// Image for UIKit
class GUAvatarImageView: UIImageView {
	let placeholderImage 	= Images.avatarPlaceholder
	let skeletonView		= SkeletonView(frame: .zero)
	
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
	
	func loadImage(fromURL url: String, at indexPath: IndexPath?) {
		showSkeleton()
		NetworkManager.shared.downloadImage(from: url) { [weak self] uiImage in
			guard let uiImage, let self else { return }
			DispatchQueue.main.async {
				if let indexPath, indexPath.row % 4 == 3 {
					self.image = self.invertColors(uiImage)
				} else {
					self.image = uiImage
				}
				self.hideSkeleton()
			}
		}
	}
}
