//


import UIKit
import CoreData

class NetworkManager {
	static let shared 			= NetworkManager()
	private let baseURL 		= "https://api.github.com/users"
	let cache 					= NSCache<NSString, UIImage>()
	let decoder: JSONDecoder 	= {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.userInfo[CodingUserInfoKey.context!] = CoreDataStack.shared.context
		return decoder
	}()
	
	private let operationQueue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1 // serial queue
		return queue
	}()
	
	private init() {}
	
	private func handleRetry<T: Codable>(endpoint: String, retryCount: Int, completed: @escaping (Result<T, GUError>) -> Void) {
		let delay = pow(2.0, Double(retryCount)) // power of
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			self.fetchWithRetry(endpoint: endpoint, retryCount: retryCount + 1, completed: completed)
		}
	}
	
	func fetchWithRetry<T: Codable>(endpoint: String, retryCount: Int = 0, completed: @escaping (Result<T, GUError>) -> Void) {
		guard let url = URL(string: baseURL + endpoint) else {
			completed(.failure(.invalidURL))
			return
		}
		
		let taskOperation = BlockOperation {
			let task = URLSession.shared.dataTask(with: url) { data, response, error in
				if let _ = error {
					if retryCount < 5 { // Exponential Backoff for retrying
						self.handleRetry(endpoint: endpoint, retryCount: retryCount, completed: completed)
					} else {
						completed(.failure(.unableToComplete))
					}
					return
				}
				
				guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else {
					if retryCount < 5 {
						self.handleRetry(endpoint: endpoint, retryCount: retryCount, completed: completed)
					} else {
						completed(.failure(.invalidResponse))
					}
					return
				}
				
				do {
					let decodedResponse = try self.decoder.decode(T.self, from: data)
					completed(.success(decodedResponse))
				} catch {
					if retryCount < 5 {
						self.handleRetry(endpoint: endpoint, retryCount: retryCount, completed: completed)
					} else {
						completed(.failure(.invalidData))
					}
				}
			}
			
			task.resume()
		}
		
		operationQueue.addOperation(taskOperation) // limited to 1 request at a time
	}
	
	func getUsers(sinceID: Int, completed: @escaping (Result<[User], GUError>) -> Void) {
		fetchWithRetry(endpoint: "?since=\(sinceID)", completed: completed)
	}
	
	func getUserInfo(username: String, completed: @escaping (Result<UserInfo, GUError>) -> Void) {
		fetchWithRetry(endpoint: "/\(username)", completed: completed)
	}
	
	func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
		let cacheKey = NSString(string: urlString)
		
		if let image = cache.object(forKey: cacheKey) {
			completed(image)
			return
		}
		
		guard let url = URL(string: urlString) else { return }
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil,
				  let response = response as? HTTPURLResponse, response.statusCode == 200,
				  let data = data, let image = UIImage(data: data) else {
				completed(nil)
				return
			}
			
			self.cache.setObject(image, forKey: cacheKey)
			completed(image)
		}
		
		task.resume()
	}
}
