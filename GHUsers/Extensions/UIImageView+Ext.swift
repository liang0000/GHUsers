//


import UIKit

extension UIImageView {
	// To make the color of Image inverted
	func invertColors(_ image: UIImage) -> UIImage {
		guard let cgImage = image.cgImage else { return image }
		let width = cgImage.width
		let height = cgImage.height
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		var rawData = [UInt8](repeating: 0, count: width * height * 4)
		guard let context = CGContext(data: &rawData,
									  width: width,
									  height: height,
									  bitsPerComponent: 8,
									  bytesPerRow: width * 4,
									  space: colorSpace,
									  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
			return image
		}
		
		context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		
		for x in 0..<width {
			for y in 0..<height {
				let offset = 4 * (x + y * width)
				rawData[offset] = 255 - rawData[offset] // Red
				rawData[offset + 1] = 255 - rawData[offset + 1] // Green
				rawData[offset + 2] = 255 - rawData[offset + 2] // Blue
			}
		}
		
		let invertedImage = context.makeImage().flatMap { UIImage(cgImage: $0) }
		return invertedImage ?? image
	}
}
