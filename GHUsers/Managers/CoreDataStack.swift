//


import Foundation
import CoreData

enum updateUserType {
	case note, seen
}

class CoreDataStack {
	static let shared = CoreDataStack()
	
	private init() {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Model")
		container.loadPersistentStores { storeDescription, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	var backgroundContext: NSManagedObjectContext {
		return persistentContainer.newBackgroundContext()
	}
	
	func saveUsers(users: [User]) {
		backgroundContext.perform { // background thread and async; because got lot data to save and don't want to block the queue
			for user in users {
				let userEntity = User(context: self.backgroundContext)
				userEntity.saveUserData(user: user)
			}
			
			do {
				try self.backgroundContext.save()
			} catch {
				print("Can't save users error: \(error)")
			}
		}
	}
	
	func getUsers(completed: @escaping (Result<[User], Error>) -> Void) {
		context.perform { // main thread and async; because need update UI while allowing other queue to run
			let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
			let sort = NSSortDescriptor(key: "id", ascending: true) // sort by id
			fetchRequest.sortDescriptors = [sort]
			
			do {
				let users = try self.context.fetch(fetchRequest)
				completed(.success(users))
			} catch {
				completed(.failure(error))
			}
		}
	}
	
	func updateUser(info userInfo: UserInfo, dataType: updateUserType) {
		context.performAndWait { // main thread and sync; because need update UI and don't want other queue to run before this
			let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "login == %@", userInfo.login ?? "") // pick wanted user
			
			do {
				let storedUsers = try self.context.fetch(fetchRequest)
				if let userToUpdate = storedUsers.first {
					switch dataType {
						case .note:
							userToUpdate.note = userInfo.note ?? ""
						case .seen:
							userToUpdate.isSeen = true
					}
					try self.context.save()
				}
			} catch {
				print("Can't save update error: \(error)")
			}
		}
	}
	
	func saveUserInfo(info userInfo: UserInfo) {
		backgroundContext.perform {
			let userInfoEntity = UserInfo(context: self.backgroundContext)
			userInfoEntity.saveUserInfoData(userInfo: userInfo)
			
			do {
				try self.backgroundContext.save()
			} catch {
				print("Can't save user info error: \(error)")
			}
		}
	}
	
	func getUserInfo(completed: @escaping (Result<[UserInfo], GUError>) -> Void) {
		context.perform {
			let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
			
			do {
				let userInfo = try self.context.fetch(fetchRequest)
				completed(.success(userInfo))
			} catch {
				completed(.failure(.unableToLoadUserInfo))
			}
		}
	}
	
	func updateUserInfo(info userInfo: UserInfo, completed: @escaping (GUError?) -> Void) {
		context.performAndWait {
			let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "login == %@", userInfo.login ?? "")
			
			do {
				let storedUserInfo = try self.context.fetch(fetchRequest)
				if let userInfoToUpdate = storedUserInfo.first {
					userInfoToUpdate.note = userInfo.note
					try self.context.save()
				}
				completed(nil)
			} catch {
				completed(.unableToLoadUserInfo)
			}
		}
	}
}

extension CodingUserInfoKey {
	static let context = CodingUserInfoKey(rawValue: "context")
}

extension User {
	func saveUserData(user: User) {
		id         = Int64(user.id)
		login      = user.login
		avatarUrl  = user.avatarUrl
		note       = user.note
		isSeen     = user.isSeen
	}
}

extension UserInfo {
	static let sampleData: [UserInfo] = {
		let userInfo1        = UserInfo(context: CoreDataStack.shared.context)
		userInfo1.id         = 9743939
		userInfo1.login      = "tawk"
		userInfo1.avatarUrl  = "https://avatars.githubusercontent.com/u/9743939?v=4"
		userInfo1.followers  = 15
		userInfo1.following  = 0
		userInfo1.name       = "tawk.to"
		userInfo1.bio        = nil
		userInfo1.note       = "One of the biggest dreams of mine is working in tawk.to"
		
		return [userInfo1]
	}()
	
	func saveUserInfoData(userInfo: UserInfo) {
		id          = Int64(userInfo.id)
		name        = userInfo.name
		login       = userInfo.login
		avatarUrl   = userInfo.avatarUrl
		note        = userInfo.note
		bio         = userInfo.bio
		blog        = userInfo.blog
		company     = userInfo.company
		followers   = userInfo.followers
		following   = userInfo.following
	}
}
