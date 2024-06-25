//


import Foundation
import CoreData

// MARK: Not using for now
/*
class CoreDataStack {
	static let shared = CoreDataStack()
	
	private init() {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "GitHubUserModel")
		container.loadPersistentStores { description, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	// hasChanges, fetch; fetch entity, perform, save
	var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	var backgroundContext: NSManagedObjectContext {
		return persistentContainer.newBackgroundContext()
	}
	
	// Load users from Core Data
	func loadUsers(completion: @escaping ([User]?) -> Void) {
		let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
		viewContext.perform {
			do {
				let userEntities = try self.viewContext.fetch(fetchRequest)
				let users = userEntities.map { $0.toUser() }
				completion(users)
			} catch {
				completion(nil)
			}
		}
	}
	
	// Save users to Core Data
	func saveUsers(users: [User]) {
		backgroundContext.perform {
			for user in users {
				let userEntity = UserEntity(context: self.backgroundContext)
				userEntity.fromUser(user: user)
			}
			do {
				try self.backgroundContext.save()
			} catch {
				print("Failed to save users to Core Data: \(error)")
			}
		}
	}
	
	// Load User Info from Core Data
	func loadUserInfo(username: String, completion: @escaping (UserInfoEntity?) -> Void) {
		let fetchRequest: NSFetchRequest<UserInfoEntity> = UserInfoEntity.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "login == %@", username)
		
		viewContext.perform {
			do {
				let userInfo = try self.viewContext.fetch(fetchRequest).first
				completion(userInfo)
			} catch {
				completion(nil)
			}
		}
	}
	
	// Save User Info to Core Data
	func saveUserInfo(userInfo: UserInfo, note: String?, completion: (() -> Void)? = nil) {
		backgroundContext.perform {
			let fetchRequest: NSFetchRequest<UserInfoEntity> = UserInfoEntity.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "login == %@", userInfo.login)
			
			do {
				let userInfoEntity: UserInfoEntity
				if let fetchedEntity = try self.backgroundContext.fetch(fetchRequest).first {
					userInfoEntity = fetchedEntity
				} else {
					userInfoEntity = UserInfoEntity(context: self.backgroundContext)
				}
				
				userInfoEntity.fromUserInfo(userInfo: userInfo, note: note)
				
				try self.backgroundContext.save()
				completion?()
			} catch {
				completion?()
			}
		}
	}
}

extension UserEntity {
	func toUser() -> User { // return user
		return User(id: Int(id), login: login ?? "", avatarUrl: avatarUrl ?? "", type: type ?? "")
	}
	
	func fromUser(user: User) { // save user
		self.id = Int64(user.id)
		self.login = user.login
		self.avatarUrl = user.avatarUrl
		self.type = user.type
	}
}

extension UserInfoEntity {
	func fromUserInfo(userInfo: UserInfo, note: String?) { // save user info
		self.id = Int64(userInfo.id)
		self.login = userInfo.login
		self.avatarUrl = userInfo.avatarUrl
		self.bio = userInfo.bio
		self.blog = userInfo.blog
		self.company = userInfo.company
		self.followers = Int32(userInfo.followers)
		self.following = Int32(userInfo.following)
		self.name = userInfo.name
		self.note = note
	}
}
*/
