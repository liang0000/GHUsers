//


import Foundation

struct UserInfo: Codable, Hashable {
	let id: Int
	let login: String
	let avatarUrl: String
	let followers: Int
	let following: Int
	var name: String?
	var company: String?
	var blog: String?
	var bio: String?
	var note: String?
}

extension UserInfo {
	static let sampleData: [UserInfo] = [
		UserInfo(id: 9743939, login: "tawk", avatarUrl: "https://avatars.githubusercontent.com/u/9743939?v=4", followers: 15, following: 0, name: "tawk.to", bio: nil, note: "I am writing notes in here")
	]
}
