//


import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject, Codable {
	enum CodingKeys: CodingKey {
		case id, login, avatarUrl, note, isSeen
	}
	
	required convenience public init(from decoder: Decoder) throws {
		guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
			fatalError("Failed to decode User - no context provided.")
		}
		self.init(context: context)
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int64.self, forKey: .id)
		self.login = try container.decode(String.self, forKey: .login)
		self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
		self.note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
		self.isSeen = try container.decodeIfPresent(Bool.self, forKey: .isSeen) ?? false
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(login, forKey: .login)
		try container.encode(avatarUrl, forKey: .avatarUrl)
		try container.encode(note, forKey: .note)
		try container.encode(isSeen, forKey: .isSeen)
	}
}
