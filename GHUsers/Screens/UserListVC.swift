//


import UIKit
import CoreData

class UserListVC: UITableViewController {
	let searchController 		= UISearchController(searchResultsController: nil)
	var users: [User] 			= []
	var filteredUsers: [User] 	= []
	var sinceID: Int 			= 0
	var lastLoadTime: Date?
	var isFiltering: Bool {
		searchController.isActive && !searchController.searchBar.text!.isEmpty
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureTableView()
		configureSearchController()
		setupNetworkChangeListener()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadUsers()
	}
	
	private func configureTableView() {
		tableView.frame         = view.bounds // fill the whole screen
		tableView.rowHeight     = 80
		tableView.delegate      = self
		tableView.dataSource    = self
		tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseID)
	}
	
	private func configureSearchController() {
		searchController.searchResultsUpdater 					= self
		searchController.searchBar.placeholder 					= "Search Users"
		searchController.obscuresBackgroundDuringPresentation 	= false
		navigationItem.searchController 						= searchController
		definesPresentationContext 								= true
	}
	
	private func setupNetworkChangeListener() {
		NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .networkStatusChanged, object: nil)
	}
	
	@objc private func networkStatusChanged() {
		if NetworkMonitor.shared.isConnected && shouldLoadUsers() {
			loadUsers()
		}
	}
	
	private func shouldLoadUsers() -> Bool {
		guard let lastLoadTime = lastLoadTime else {
			return true
		}
		return Date().timeIntervalSince(lastLoadTime) > 10 // adjust the interval
	}
	
	// Load users from Database
	private func loadUsers() {
		lastLoadTime = Date()
		CoreDataStack.shared.getUsers { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let storedUsers):
					self.sinceID = Int(storedUsers.last?.id ?? Int64(self.sinceID))
					if storedUsers.isEmpty {
						self.fetchUsers()
					} else {
						self.users = storedUsers
						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					}
					
				case .failure(let error):
					self.fetchUsers()
					print("Can't retrieve users error: \(error)")
			}
		}
	}
	
	// Fetch users from Internet
	private func fetchUsers() {
		tableView.showLoadingFooter()
		NetworkManager.shared.getUsers(sinceID: sinceID) { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let fetchedUsers):
					self.sinceID = Int(fetchedUsers.last?.id ?? Int64(self.sinceID))
					self.users.append(contentsOf: fetchedUsers)
					CoreDataStack.shared.saveUsers(users: fetchedUsers)
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				case .failure(let error):
					self.showAlert(title: "Something went wrong", message: error.rawValue)
			}
			DispatchQueue.main.async {
				self.tableView.hideLoadingFooter()
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (isFiltering ? filteredUsers : users).count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseID) as! UserCell
		let user = (isFiltering ? filteredUsers : users)[indexPath.row]
		cell.set(user: user, at: indexPath)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // after select a cell
		let user = (isFiltering ? filteredUsers : users)[indexPath.row]
		let infoVC = UserInfoVC(username: user.login!)
		show(infoVC, sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { // load more when reached last cell
		if !isFiltering && indexPath.row == users.count - 1 {
			fetchUsers()
		}
	}
}

// Search Func
extension UserListVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
			filteredUsers = users
			tableView.reloadData()
			return
		}
		
		filterContentForSearchText(searchText)
	}
	
	func filterContentForSearchText(_ searchText: String) {
		let searchWords = searchText.lowercased().split(separator: " ").map { String($0) }
		
		filteredUsers = users.filter { user in
			let combinedString = (user.login! + " " + (user.note ?? "")).lowercased()
			return searchWords.allSatisfy { combinedString.contains($0) }
		}
		tableView.reloadData()
	}
}
