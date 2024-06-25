//


import SwiftUI

// Image for SwiftUI
final class ImageLoader: ObservableObject {
	@Published var image: Image? = nil
	
	func loadImage(fromURL url: String) {
		NetworkManager.shared.downloadImage(from: url) { uiImage in
			guard let uiImage = uiImage else { return }
			DispatchQueue.main.async {
				self.image = Image(uiImage: uiImage)
			}
		}
	}
}

struct RemoteImage: View {
	var image: Image?
	
	var body: some View {
		image?.resizable() ?? Image(systemName: "person").resizable()
	}
}

struct GUImage: View {
	@StateObject private var imageLoader = ImageLoader()
	var url: String
	
	var body: some View {
		RemoteImage(image: imageLoader.image)
			.onAppear { imageLoader.loadImage(fromURL: url) }
	}
}

