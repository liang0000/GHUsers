//


import UIKit

class UserCell: UITableViewCell {
	static let reuseID  			= "UserCell"
	let avatarImageView 			= GUAvatarImageView(frame: .zero)
	let usernameLabel   			= GULabel(labelType: .primary, fontSize: 22)
	let detailLabel   				= GULabel(labelType: .secondary, fontSize: 14)
	let noteIcon					= GUIconImageView(icon: Images.noteTextIcon!)
	let padding: CGFloat 			= 12
	let paddingTrailing: CGFloat 	= 40
	private var user: User?
	
	private var usernameTrailingConstraint: NSLayoutConstraint?
	private var usernameYAnchorConstraint: NSLayoutConstraint?
	private var detailTrailingConstraint: NSLayoutConstraint?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// if system appearance changed (light or dark mode)
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		cellBackgroundColor()
	}
	
	func set(user: User, at indexPath: IndexPath) {
		self.user = user
		let hasNote: Bool = user.note == nil || user.note?.isEmpty == true
		
		avatarImageView.loadImage(fromURL: user.avatarUrl!, at: indexPath)
		usernameLabel.setText(user.login)
		detailLabel.setText(user.note)
		noteIcon.isHidden = hasNote
		detailLabel.isHidden = hasNote
		updateConstraintsForNote(hasNote: !hasNote)
		cellBackgroundColor()
	}
	
	private func configure() {
		addSubviews(avatarImageView, usernameLabel, detailLabel, noteIcon)
		
		accessoryType = .disclosureIndicator
		
		NSLayoutConstraint.activate([
			avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
			avatarImageView.heightAnchor.constraint(equalToConstant: 60),
			avatarImageView.widthAnchor.constraint(equalToConstant: 60),
			
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
			usernameLabel.heightAnchor.constraint(equalToConstant: 30),
			
			detailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
			detailLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
			detailLabel.heightAnchor.constraint(equalToConstant: 24),
			
			noteIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
			noteIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingTrailing),
			noteIcon.heightAnchor.constraint(equalToConstant: 25),
			noteIcon.widthAnchor.constraint(equalToConstant: 25),
		])
	}
	
	private func updateConstraintsForNote(hasNote: Bool) {
		usernameTrailingConstraint?.isActive = false
		usernameYAnchorConstraint?.isActive = false
		detailTrailingConstraint?.isActive = false
		
		usernameTrailingConstraint = usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingTrailing - (hasNote ? 30 : 0))
		if hasNote {
			usernameYAnchorConstraint = usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding)
		} else {
			usernameYAnchorConstraint = usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		}
		detailTrailingConstraint = detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingTrailing - (hasNote ? 30 : 0))
		
		usernameTrailingConstraint?.isActive = true
		usernameYAnchorConstraint?.isActive = true
		detailTrailingConstraint?.isActive = true
	}
	
	// manage cell background if user info is seen
	private func cellBackgroundColor() {
		guard let isSeen = user?.isSeen, isSeen == true else {
			contentView.backgroundColor = .clear
			return
		}
		
		if traitCollection.userInterfaceStyle == .light {
			contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
		} else {
			contentView.backgroundColor = UIColor(white: 0, alpha: 0.5)
		}
	}
}
