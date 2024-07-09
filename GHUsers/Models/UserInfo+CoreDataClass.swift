//


import Foundation
import CoreData

@objc(UserInfo)
public class UserInfo: NSManagedObject, Codable {
	enum CodingKeys: CodingKey {
		case id, login, avatarUrl, followers, following, name, company, blog, bio, note
	}
	
	required convenience public init(from decoder: Decoder) throws {
		guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
			fatalError("Failed to decode UserInfo - no context provided.")
		}
		self.init(context: context)
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int64.self, forKey: .id)
		self.login = try container.decode(String.self, forKey: .login)
		self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
		self.followers = try container.decode(Int32.self, forKey: .followers)
		self.following = try container.decode(Int32.self, forKey: .following)
		self.name = try container.decodeIfPresent(String.self, forKey: .name)
		self.company = try container.decodeIfPresent(String.self, forKey: .company)
		self.blog = try container.decodeIfPresent(String.self, forKey: .blog)
		self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
		self.note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(login, forKey: .login)
		try container.encode(avatarUrl, forKey: .avatarUrl)
		try container.encode(followers, forKey: .followers)
		try container.encode(following, forKey: .following)
		try container.encode(name, forKey: .name)
		try container.encode(company, forKey: .company)
		try container.encode(blog, forKey: .blog)
		try container.encode(bio, forKey: .bio)
		try container.encode(note, forKey: .note)
	}
}
