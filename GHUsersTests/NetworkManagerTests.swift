//


import XCTest
@testable import GHUsers

class NetworkManagerTests: XCTestCase {
	
	var networkManager: NetworkManager!
	
	override func setUp() {
		super.setUp()
		networkManager = NetworkManager.shared
	}
	
	override func tearDown() {
		networkManager = nil
		super.tearDown()
	}
	
	func testGetUsers() {
		let expectation = self.expectation(description: "Fetching users")
		
		networkManager.getUsers(sinceID: 0) { result in
			switch result {
				case .success(let users):
					XCTAssertNotNil(users, "Users should not be nil")
					XCTAssertEqual(users.count, 30, "Users count should be 30")
				case .failure(let error):
					XCTFail("Failed to fetch users: \(error.localizedDescription)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testGetUserInfo() {
		let expectation = self.expectation(description: "Fetching user info")
		
		networkManager.getUserInfo(username: "tawk") { result in
			switch result {
				case .success(let userInfo):
					XCTAssertNotNil(userInfo, "login should not be nil")
					XCTAssertEqual(userInfo.login, "tawk", "login should match")
				case .failure(let error):
					XCTFail("Failed to fetch user info: \(error.localizedDescription)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testInvalidData() {
		let expectation = self.expectation(description: "Fetching with invalid data")
		
		networkManager.fetchWithRetry(endpoint: "/invaliddata") { (result: Result<[User], GUError>) in
			switch result {
				case .success:
					XCTFail("Expected failure for invalid data")
				case .failure(let error):
					XCTAssertEqual(error, .invalidData, "Error should be invalidData")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 32, handler: nil) // 1+1+2+4+8+16
	}
	
	func testImageDownload() {
		let expectation = self.expectation(description: "Downloading image")
		
		let imageUrl = "https://avatars.githubusercontent.com/u/9743939?v=4"
		networkManager.downloadImage(from: imageUrl) { image in
			XCTAssertNotNil(image, "Image should not be nil")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testImageDownloadInvalidURL() {
		let expectation = self.expectation(description: "Downloading image with invalid URL")
		
		let imageUrl = "invalid_url"
		networkManager.downloadImage(from: imageUrl) { image in
			XCTAssertNil(image, "Image should be nil for invalid URL")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testImageDownloadCaching() {
		let expectation1 = self.expectation(description: "Downloading image first time")
		let expectation2 = self.expectation(description: "Downloading image second time")
		
		let imageUrl = "https://avatars.githubusercontent.com/u/9743939?v=4"
		networkManager.downloadImage(from: imageUrl) { image in
			XCTAssertNotNil(image, "Image should not be nil")
			expectation1.fulfill()
			
				// Download again to test caching
			self.networkManager.downloadImage(from: imageUrl) { cachedImage in
				XCTAssertNotNil(cachedImage, "Cached image should not be nil")
				XCTAssertEqual(image, cachedImage, "Cached image should be the same as the first downloaded image")
				expectation2.fulfill()
			}
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
}
