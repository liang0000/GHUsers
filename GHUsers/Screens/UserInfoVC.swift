//


import UIKit
import SwiftUI

class UserInfoVC: UIViewController {
	var username: String!
	var info: UserInfo?
	
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
		loadUserInfo()
	}
	
	// Load users from Database
	func loadUserInfo() {
		PersistenceManager.retrieveUserInfo { [weak self] result in
			guard let self else { return }
			
			switch result {
				case .success(let storedUserInfo):
					if let index = storedUserInfo.firstIndex(where: { $0.login == self.username }) {
						info = storedUserInfo[index]
						DispatchQueue.main.async {
							self.setupProfileView()
						}
					} else {
						getUserInfo()
					}
					
				case .failure(let error):
					print(error)
					DispatchQueue.main.async {
						self.showAlert(title: "Something went wrong.", message: error.rawValue)
					}
			}
		}
	}
	
	// Load users from Internet
	func getUserInfo() {
		showLoadingView()
		NetworkManager.shared.getUserInfo(username: username) { [weak self] result in
			guard let self = self else { return }
			switch result {
				case .success(let info):
					self.info = info
					DispatchQueue.main.async {
						self.setupProfileView()
					}
					PersistenceManager.updateUserInfo(info: info) { [weak self] error in
						guard let self = self else { return }
						if let error {
							showAlert(title: "Something went wrong", message: error.rawValue)
						}
					}
				case .failure(let error):
					showAlert(title: "Something went wrong", message: error.rawValue) {
						self.navigationController?.popViewController(animated: true)
					}
			}
			dismissLoadingView()
		}
	}
	
	// Save note to Database
	func saveNote(_ note: String) {
		guard var info = info else { return }
		info.note = note
		PersistenceManager.updateUserInfo(info: info) { [weak self] error in
			guard let self = self else { return }
			if let error {
				showAlert(title: "Something went wrong", message: error.rawValue)
				return
			}
			
			showToast(message: "Successfully Saved")
		}
	}
	
	func setupProfileView() {
		guard let info = info else { return }
		
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
