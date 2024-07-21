//


import UIKit

class NetworkMonitor {
	static let shared = NetworkMonitor()
	private let reachability = try! Reachability()
	var didChangeStatus: (() -> Void)?
	
	var isConnected: Bool {
		return reachability.connection != .unavailable
	}
	
	private init() {
		reachability.whenReachable = { reachability in
			self.didChangeStatus?()
		}
		reachability.whenUnreachable = { reachability in
			self.didChangeStatus?()
		}
		
		do {
			try reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
	}
}

extension Notification.Name {
	static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
