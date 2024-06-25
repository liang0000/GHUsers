//


import UIKit

class UserCell: UITableViewCell {
	static let reuseID  			= "UserCell"
	let avatarImageView 			= GUAvatarImageView(frame: .zero)
	let usernameLabel   			= GUTitleLabel(textAlignment: .left, fontSize: 22)
	let detailLabel   				= GUSecTitleLabel(fontSize: 14)
	let noteIcon					= UIImageView(image: UIImage(systemName: "note.text"))
	let padding: CGFloat 			= 12
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func set(user: User, savedNote: Bool) {
		avatarImageView.loadImage(fromURL: user.avatarUrl)
		usernameLabel.text 	= user.login
		detailLabel.text	= user.type
		noteIcon.isHidden	= !savedNote
	}
	
	private func configure() {
		addSubviews(avatarImageView, usernameLabel, detailLabel, noteIcon)
		
		accessoryType = .disclosureIndicator // tappable and more to see
		noteIcon.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
			avatarImageView.heightAnchor.constraint(equalToConstant: 60),
			avatarImageView.widthAnchor.constraint(equalToConstant: 60),
			
			usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
			usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
			usernameLabel.heightAnchor.constraint(equalToConstant: 30),
			
			detailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
			detailLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
			detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
			detailLabel.heightAnchor.constraint(equalToConstant: 24),
			
			noteIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
			noteIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
			noteIcon.heightAnchor.constraint(equalToConstant: 25),
			noteIcon.widthAnchor.constraint(equalToConstant: 25),
		])
	}
}
