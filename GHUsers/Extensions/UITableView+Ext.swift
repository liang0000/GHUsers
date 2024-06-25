//


import UIKit

extension UITableView {
	func showLoadingFooter() {
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		footerView.addSubview(activityIndicator)
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
		])
		DispatchQueue.main.async {
			activityIndicator.startAnimating()
			self.tableFooterView = footerView
		}
	}
	
	func hideLoadingFooter() {
		tableFooterView = nil
	}
}
