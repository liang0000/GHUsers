//


import UIKit
import CoreData

class UserListVC: UITableViewController {
	let searchController 		= UISearchController(searchResultsController: nil)
	var users: [User] 			= []
	var filteredUsers: [User] 	= []
	var sinceID: Int 			= 0
	var isFiltering: Bool {
		searchController.isActive && !searchController.searchBar.text!.isEmpty
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureTableView()
		configureSearchController()
		loadUsers()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadUsers()
	}

	
	func configureTableView() {
		tableView.frame         = view.bounds // fill the whole screen
		tableView.rowHeight     = 80
		tableView.delegate      = self
		tableView.dataSource    = self
		tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseID)
	}
	
	func configureSearchController() {
		searchController.searchResultsUpdater 					= self
		searchController.searchBar.placeholder 					= "Search Users"
		searchController.obscuresBackgroundDuringPresentation 	= false
		navigationItem.searchController 						= searchController
		definesPresentationContext 								= true
	}
	
	// Load users from Database
	func loadUsers() {
		PersistenceManager.retrieveUsers { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let users):
					sinceID = users.last?.id ?? sinceID
					if users.isEmpty {
						self.fetchUsers()
					} else {
						self.users = users
						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					}
				case .failure(let error):
					fetchUsers()
					print("Can't retrieve users error: \(error)")
			}
		}
	}
	
	// Fetch users from Internet
	func fetchUsers() {
		tableView.showLoadingFooter()
		NetworkManager.shared.getUsers(sinceID: sinceID) { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let fetchedUsers):
					sinceID = fetchedUsers.last?.id ?? sinceID
					users.append(contentsOf: fetchedUsers)
					PersistenceManager.updateUsers(users: fetchedUsers)
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				case .failure(let error):
					showAlert(title: "Something went wrong", message: error.rawValue)
			}
			DispatchQueue.main.async {
				self.tableView.hideLoadingFooter()
			}
		}
	}
	
	func checkUserSavedNote(user: User) -> Bool {
		var savedNote: Bool = false
		PersistenceManager.retrieveUserInfo { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let fetchedUserInfo):
					if let index = fetchedUserInfo.firstIndex(where: { $0.login == user.login }) {
						savedNote = fetchedUserInfo[index].note?.isEmpty == false
					}
					
				case .failure( _):
					savedNote = false
			}
		}
		return savedNote
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (isFiltering ? filteredUsers : users).count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseID) as! UserCell
		let user = (isFiltering ? filteredUsers : users)[indexPath.row]
		let savedNote: Bool = checkUserSavedNote(user: user)
		cell.set(user: user, savedNote: savedNote)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // after select a cell
		let user = (isFiltering ? filteredUsers : users)[indexPath.row]
		let infoVC = UserInfoVC(username: user.login)
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
		filteredUsers = users.filter { user in
			user.login.lowercased().contains(searchText.lowercased()) ||
			user.login.lowercased() == searchText.lowercased()
		}
		tableView.reloadData()
	}
}



