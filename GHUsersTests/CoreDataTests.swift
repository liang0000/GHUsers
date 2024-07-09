//


import XCTest
import CoreData
@testable import GHUsers

class CoreDataStackTests: XCTestCase {
	
	var persistentContainer: NSPersistentContainer!
	var managedObjectContext: NSManagedObjectContext!
	
	override func setUpWithError() throws {
		persistentContainer = NSPersistentContainer(name: "Model")
		
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		
		persistentContainer.persistentStoreDescriptions = [description]
		
		persistentContainer.loadPersistentStores { (description, error) in
			XCTAssertNil(error)
		}
		
		managedObjectContext = persistentContainer.viewContext
		CoreDataStack.shared.persistentContainer = persistentContainer
	}
	
	override func tearDownWithError() throws {
		managedObjectContext = nil
		persistentContainer = nil
	}
	
	func testSaveUsers() throws {
		let user 		= User(context: managedObjectContext)
		user.id 		= 1
		user.login 		= "testUser"
		user.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		user.note 		= "Test note"
		user.isSeen 	= false
		
		CoreDataStack.shared.saveUsers(users: [user])
		
		let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
		let fetchedUsers = try managedObjectContext.fetch(fetchRequest)
		
		XCTAssertEqual(fetchedUsers.count, 1)
		XCTAssertEqual(fetchedUsers.first?.login, "testUser")
	}
	
	func testGetUsers() throws {
		let user 		= User(context: managedObjectContext)
		user.id 		= 1
		user.login 		= "testUser"
		user.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		user.note 		= "Test note"
		user.isSeen 	= false
		
		try managedObjectContext.save()
		
		let expectation = self.expectation(description: "Fetching users")
		
		CoreDataStack.shared.getUsers { result in
			switch result {
				case .success(let users):
					XCTAssertEqual(users.count, 1)
					XCTAssertEqual(users.first?.login, "testUser")
				case .failure(let error):
					XCTFail("Error fetching users: \(error)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testUpdateUserNote() throws {
		let user 		= User(context: managedObjectContext)
		user.id 		= 1
		user.login 		= "testUser"
		user.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		user.note 		= "Old note"
		user.isSeen		= false
		
		try managedObjectContext.save()
		
		let userInfo 	= UserInfo(context: managedObjectContext)
		userInfo.login 	= "testUser"
		userInfo.note 	= "New note"
		
		CoreDataStack.shared.updateUser(info: userInfo, dataType: .note)
		
		let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "login == %@", "testUser")
		
		let fetchedUsers = try managedObjectContext.fetch(fetchRequest)
		
		XCTAssertEqual(fetchedUsers.first?.note, "New note")
	}
	
	func testUpdateUserSeen() throws {
		let user 		= User(context: managedObjectContext)
		user.id 		= 1
		user.login 		= "testUser"
		user.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		user.note 		= "Test note"
		user.isSeen 	= false
		
		try managedObjectContext.save()
		
		let userInfo = UserInfo(context: managedObjectContext)
		userInfo.login = "testUser"
		
		CoreDataStack.shared.updateUser(info: userInfo, dataType: .seen)
		
		let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "login == %@", "testUser")
		
		let fetchedUsers = try managedObjectContext.fetch(fetchRequest)
		
		XCTAssertTrue(fetchedUsers.first!.isSeen)
	}
	
	func testSaveUserInfo() throws {
		let userInfo 		= UserInfo(context: managedObjectContext)
		userInfo.id 		= 1
		userInfo.login 		= "testUser"
		userInfo.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		userInfo.followers 	= 10
		userInfo.following 	= 5
		userInfo.name 		= "Test User"
		userInfo.bio 		= "Test bio"
		userInfo.note 		= "Test note"
		
		CoreDataStack.shared.saveUserInfo(info: userInfo)
		
		let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
		let fetchedUserInfo = try managedObjectContext.fetch(fetchRequest)
		
		XCTAssertEqual(fetchedUserInfo.count, 1)
		XCTAssertEqual(fetchedUserInfo.first?.login, "testUser")
	}
	
	func testGetUserInfo() throws {
		let userInfo 		= UserInfo(context: managedObjectContext)
		userInfo.id 		= 1
		userInfo.login 		= "testUser"
		userInfo.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		userInfo.followers 	= 10
		userInfo.following 	= 5
		userInfo.name 		= "Test User"
		userInfo.bio 		= "Test bio"
		userInfo.note 		= "Test note"
		
		try managedObjectContext.save()
		
		let expectation = self.expectation(description: "Fetching user info")
		
		CoreDataStack.shared.getUserInfo { result in
			switch result {
				case .success(let userInfo):
					XCTAssertEqual(userInfo.count, 1)
					XCTAssertEqual(userInfo.first?.login, "testUser")
				case .failure(let error):
					XCTFail("Error fetching user info: \(error)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testUpdateUserInfo() throws {
		let userInfo 		= UserInfo(context: managedObjectContext)
		userInfo.id 		= 9743939
		userInfo.login 		= "tawk"
		userInfo.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		userInfo.followers 	= 16
		userInfo.following 	= 0
		userInfo.name 		= "tawk.to"
		userInfo.bio 		= "https://www.tawk.to"
		userInfo.note 		= ""
		
		try managedObjectContext.save()
		
		let updatedUserInfo = UserInfo(context: managedObjectContext)
		updatedUserInfo.login 		= "tawk"
		updatedUserInfo.avatarUrl 	= "https://avatars.githubusercontent.com/u/1?v=4"
		updatedUserInfo.note		= "New note"
		
		let expectation = self.expectation(description: "Updating user info")
		
		CoreDataStack.shared.updateUserInfo(info: updatedUserInfo) { error in
			XCTAssertNil(error, "Expected no error")
			
			let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "login == %@", "tawk")
			
			let fetchedUserInfo = try! self.managedObjectContext.fetch(fetchRequest)
			
			XCTAssertEqual(fetchedUserInfo.first?.note, "New note")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
}
