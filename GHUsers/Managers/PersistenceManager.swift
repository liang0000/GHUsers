//


import Foundation

enum PersistenceManager {
	static private let defaults = UserDefaults.standard
	
	enum Keys {
		static let users = "users"
		static let userInfo = "userInfo"
	}
	
	static func saveUsers(users: [User]) -> Error? {
		do {
			let encoder = JSONEncoder()
			let encodedUsers = try encoder.encode(users)
			defaults.set(encodedUsers, forKey: Keys.users)
			return nil
		} catch {
			return error
		}
	}
	
	static func retrieveUsers(completed: @escaping (Result<[User], Error>) -> Void) {
		guard let usersData = defaults.object(forKey: Keys.users) as? Data else {
			completed(.success([]))
			return
		}
		
		do {
			let decoder = JSONDecoder()
			let users = try decoder.decode([User].self, from: usersData)
			completed(.success(users))
		} catch {
			completed(.failure(error))
		}
	}
	
	static func updateUsers(users newUsers: [User]) {
		retrieveUsers { result in
			switch result {
				case .success(var storedUsers):
					let newUniqueUsers = newUsers.filter { newUser in
						!storedUsers.contains { $0.login == newUser.login }
					}
					storedUsers.append(contentsOf: newUniqueUsers)
					if let error = saveUsers(users: storedUsers) {
						print("Can't save users error: \(error)")
					}
					
				case .failure(let error):
					print("Can't save retrieve error: \(error)")
			}
		}
	}
	
	static func saveUserInfo(info userInfo: [UserInfo]) -> GUError? {
		do {
			let encoder = JSONEncoder()
			let encodedUsers = try encoder.encode(userInfo)
			defaults.set(encodedUsers, forKey: Keys.userInfo)
			return nil
		} catch {
			return .unableToSaveUserInfo
		}
	}
	
	static func retrieveUserInfo(completed: @escaping (Result<[UserInfo], GUError>) -> Void) {
		guard let userInfoData = defaults.object(forKey: Keys.userInfo) as? Data else {
			completed(.success([]))
			return
		}
		
		do {
			let decoder = JSONDecoder()
			let userInfo = try decoder.decode([UserInfo].self, from: userInfoData)
			completed(.success(userInfo))
		} catch {
			completed(.failure(.unableToLoadUserInfo))
		}
	}
	
	static func updateUserInfo(info userInfo: UserInfo, completed: @escaping (GUError?) -> Void) {
		retrieveUserInfo { result in
			switch result {
				case .success(var storedUserInfo):
					if let index = storedUserInfo.firstIndex(where: { $0.login == userInfo.login }) {
						storedUserInfo[index] = userInfo
					} else {
						storedUserInfo.append(userInfo)
					}
					completed(saveUserInfo(info: storedUserInfo))
					
				case .failure(let error):
					completed(error)
			}
		}
	}
}
