//


import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
	func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
			completion?()
		}))
		DispatchQueue.main.async {
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func showToast(message: String, duration: TimeInterval = 2.0) {
		let toastLabel 				= UILabel()
		toastLabel.text 			= message
		toastLabel.textColor 		= .white
		toastLabel.backgroundColor 	= UIColor.black.withAlphaComponent(0.6)
		toastLabel.textAlignment	= .center
		toastLabel.font				= UIFont.systemFont(ofSize: 14)
		toastLabel.numberOfLines 	= 0
		toastLabel.alpha 			= 0.0
		toastLabel.layer.cornerRadius = 10
		toastLabel.clipsToBounds 	= true
		
		let maxSizeTitle = CGSize(width: self.view.bounds.size.width - 40, height: self.view.bounds.size.height)
		var expectedSizeTitle = toastLabel.sizeThatFits(maxSizeTitle)
		expectedSizeTitle = CGSize(width: min(maxSizeTitle.width, expectedSizeTitle.width), height: min(maxSizeTitle.height, expectedSizeTitle.height))
		toastLabel.frame = CGRect(x: 20, y: self.view.bounds.size.height - 100, width: self.view.bounds.size.width - 40, height: expectedSizeTitle.height + 20)
		toastLabel.center.x = self.view.center.x
		
		self.view.addSubview(toastLabel)
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
			toastLabel.alpha = 1.0
		}, completion: { _ in
			UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
				toastLabel.alpha = 0.0
			}, completion: { _ in
				toastLabel.removeFromSuperview()
			})
		})
	}

	func showLoadingView() {
		containerView = UIView(frame: view.bounds) // fill the whole screen
		view.addSubview(containerView)
		
		containerView.backgroundColor = .systemBackground
		containerView.alpha = 0 // opacity
		
		UIView.animate(withDuration: 0.25) {
			containerView.alpha = 0.8
		}
		
		let activityIndicator = UIActivityIndicatorView(style: .large)
		containerView.addSubview(activityIndicator)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
		])
		
		activityIndicator.startAnimating()
	}
	
	func dismissLoadingView() {
		DispatchQueue.main.async {
			containerView.removeFromSuperview()
			containerView = nil
		}
	}
}
