//


import Foundation
import CoreData

struct User: Codable, Hashable  {
	var id: Int
	var login: String
	var avatarUrl: String
	var type: String
	var note: String?
	var isSeen: Bool?
}
