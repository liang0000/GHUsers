//


import UIKit
import SwiftUI

class UserInfoVC: UIViewController {
	var username: String!
	var userInfo: UserInfo?
	
	init(username: String) {
		super.init(nibName: nil, bundle: nil)
		self.username   = username
		title           = username
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		createDismissKeyboardTapGesture()
		loadUserInfo()
	}
	
	private func createDismissKeyboardTapGesture() {
		let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
		view.addGestureRecognizer(tap)
	}
	
	// Load user info from Database
	private func loadUserInfo() {
		CoreDataStack.shared.getUserInfo { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let storedUserInfo):
					if let index = storedUserInfo.firstIndex(where: { $0.login == self.username }) {
						self.userInfo = storedUserInfo[index]
						DispatchQueue.main.async {
							self.setupProfileView()
						}
					} else {
						self.fetchUserInfo()
					}
					
				case .failure(let error):
					DispatchQueue.main.async {
						self.showAlert(title: "Something went wrong.", message: error.rawValue)
					}
			}
		}
	}
	
	// Fetch user info from Internet
	private func fetchUserInfo() {
		showLoadingView()
		NetworkManager.shared.getUserInfo(username: username) { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let fetchedUserInfo):
					self.userInfo = fetchedUserInfo
					CoreDataStack.shared.updateUser(info: fetchedUserInfo, dataType: .seen) // save user as seen
					CoreDataStack.shared.saveUserInfo(info: fetchedUserInfo)
					DispatchQueue.main.async {
						self.setupProfileView()
					}
				case .failure(let error):
					self.showAlert(title: "Something went wrong", message: error.rawValue) {
						self.navigationController?.popViewController(animated: true)
					}
			}
			self.dismissLoadingView()
		}
	}
	
	// Save note to Database
	private func saveNote(_ note: String) {
		guard let userInfo = userInfo else { return }
		userInfo.note = note
		view.endEditing(true)
		
		CoreDataStack.shared.updateUserInfo(info: userInfo) { [weak self] error in
			guard let self else { return }
			if let error {
				self.showAlert(title: "Something went wrong", message: error.rawValue)
				return
			}
			
			CoreDataStack.shared.updateUser(info: userInfo, dataType: .note)
			self.showToast(message: "Successfully Saved")
		}
	}
	
	private func setupProfileView() {
		guard let info = userInfo else { return }
		
		let swiftUIView = UserInfoView(info: info, saveAction: saveNote)
		let hostingController = UIHostingController(rootView: swiftUIView)
		
		addChild(hostingController)
		view.addSubview(hostingController.view)
		
		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
			hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		hostingController.didMove(toParent: self)
	}
}
