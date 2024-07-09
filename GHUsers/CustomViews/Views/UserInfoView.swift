//


import SwiftUI

struct UserInfoView: View {
	var info: UserInfo
	@State private var enteredNote: String
	var saveAction: (String) -> Void
	
	init(info: UserInfo, saveAction: @escaping (String) -> Void) {
		self.info = info
		self._enteredNote = State(initialValue: info.note ?? "")
		self.saveAction = saveAction
	}
	
	var body: some View {
		ScrollView {
			GUImage(url: info.avatarUrl!)
				.scaledToFit()
				.frame(maxWidth: .infinity, maxHeight: 130)
				.clipShape(Circle())
			
			HStack(spacing: 60) {
				Text("Followers: ").bold() + Text("\(info.followers)")
				Text("Following: ").bold() + Text("\(info.following)")
			}
			
			GroupBox {
				VStack(alignment: .leading) {
					Text("Name: ").bold() + Text(info.name ?? "-")
					Text("Company: ").bold() + Text(info.company ?? "-")
					Text("Blog: ").bold() + Text(info.blog ?? "-")
					Text("Bio: ").bold() + Text(info.bio ?? "-")
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding()
			
			VStack(spacing: 5) {
				Text("NOTES")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.caption.bold())
					.foregroundColor(.secondary)
					.padding(.leading, 20)
				
				GroupBox {
					TextEditor(text: $enteredNote)
						.frame(minHeight: 170, maxHeight: 170)
				}
			}
			.padding()
			
			Button("Save") {
				saveAction(enteredNote)
			}
			.padding(.bottom, 20)
		}
	}
}

#Preview {
	UserInfoView(info: UserInfo.sampleData[0], saveAction: { _ in })
}
