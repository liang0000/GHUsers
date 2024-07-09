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
	
	private init() {}
	
	func fetch<T: Codable>(endpoint: String, completed: @escaping (Result<T, GUError>) -> Void) {
		guard let url = URL(string: baseURL + endpoint) else {
			completed(.failure(.invalidURL))
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let _ = error {
				completed(.failure(.unableToComplete))
				return
			}
			
			guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else {
				completed(.failure(.invalidResponse))
				return
			}
			
			do {
				let decodedResponse = try self.decoder.decode(T.self, from: data)
				completed(.success(decodedResponse))
			} catch {
				completed(.failure(.invalidData))
			}
		}
		
		task.resume()
	}
	
	func getUsers(sinceID: Int, completed: @escaping (Result<[User], GUError>) -> Void) {
		fetch(endpoint: "?since=\(sinceID)", completed: completed)
	}
	
	func getUserInfo(username: String, completed: @escaping (Result<UserInfo, GUError>) -> Void) {
		fetch(endpoint: "/\(username)", completed: completed)
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
