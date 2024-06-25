//


import UIKit

class NetworkManager {
	static let shared 	= NetworkManager()
	private let baseURL = "https://api.github.com/users"
	let cache 			= NSCache<NSString, UIImage>()
	let decoder         = JSONDecoder()
	
	private init() {
		decoder.keyDecodingStrategy  = .convertFromSnakeCase
	}
	
	func getUsers(sinceID: Int, completed: @escaping (Result<[User], GUError>) -> Void) {
		let endpoint = baseURL + "?since=\(sinceID)"
		guard let url = URL(string: endpoint) else {
			completed(.failure(.invalidURL))
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let _ = error {
				completed(.failure(.unableToComplete))
				return
			}
			
			guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				completed(.failure(.invalidResponse))
				return
			}
			
			guard let data else {
				completed(.failure(.invalidData))
				return
			}
			
			do {
				let decodedResponse = try self.decoder.decode([User].self, from: data)
				completed(.success(decodedResponse))
			} catch {
				completed(.failure(.invalidData))
			}
		}
		
		task.resume()
	}
	
	func getUserInfo(username: String, completed: @escaping (Result<UserInfo, GUError>) -> Void) {
		let endpoint = baseURL + "/\(username)"
		guard let url = URL(string: endpoint) else {
			completed(.failure(.invalidURL))
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let _ = error {
				completed(.failure(.unableToComplete))
				return
			}
			
			guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				completed(.failure(.invalidResponse))
				return
			}
			
			guard let data else {
				completed(.failure(.invalidData))
				return
			}
			
			do {
				let decodedResponse = try self.decoder.decode(UserInfo.self, from: data)
				completed(.success(decodedResponse))
			} catch {
				completed(.failure(.invalidData))
			}
		}
		
		task.resume()
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
				  let data = data,
				  let image = UIImage(data: data) else {
				return
			}
			
			self.cache.setObject(image, forKey: cacheKey)
			completed(image)
		}
		
		task.resume()
	}
}
