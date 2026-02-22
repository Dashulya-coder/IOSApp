//
//  PostView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//

import UIKit
import Kingfisher

final class PostView: UIView {

    // MARK: - UI
    private let cardView = UIView()

    private let headerLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)

    private let titleLabel = UILabel()
    private let postImageView = UIImageView()

    private let bottomBar = UIStackView()
    private let ratingLabel = UILabel()
    private let commentsLabel = UILabel()
    private let shareButton = UIButton(type: .system)
    private var post: Post?


    // MARK: - State
    private var saved: Bool = false {
        didSet { updateBookmarkIcon() }
    }

    var onBookmarkToggle: ((Bool) -> Void)?
    var onSaveTap: ((Post, Bool) -> Void)? 
    var onShareTap: ((Post) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
    }

    // MARK: - Public
    func configure(with post: Post) {
        self.post = post

        headerLabel.text = "\(post.username) • \(timeAgo(from: post.createdDate)) • \(post.domain)"
        titleLabel.text = post.title
        ratingLabel.text = "↑ \(formatScore(post.rating))"
        commentsLabel.text = "💬 \(post.numComments)"

        saved = post.isSaved

        if let url = post.imageURL {
            postImageView.kf.setImage(with: url)
        } else {
            postImageView.image = nil
            postImageView.backgroundColor = .tertiarySystemFill
        }
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        addSubview(cardView)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.numberOfLines = 1
        cardView.addSubview(headerLabel)

        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.tintColor = .label
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        cardView.addSubview(bookmarkButton)
        updateBookmarkIcon()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)

        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .tertiarySystemFill
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        cardView.addSubview(postImageView)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.axis = .horizontal
        bottomBar.alignment = .center
        bottomBar.distribution = .equalSpacing
        cardView.addSubview(bottomBar)

        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = .label

        commentsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        commentsLabel.textColor = .label

        var config = UIButton.Configuration.plain()
        config.title = "Share"
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = .label
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 14, weight: .semibold)
            return attrs
        }
        shareButton.configuration = config
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)

        bottomBar.addArrangedSubview(ratingLabel)
        bottomBar.addArrangedSubview(commentsLabel)
        bottomBar.addArrangedSubview(shareButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: bookmarkButton.leadingAnchor, constant: -8),

            bookmarkButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 28),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 260),

            bottomBar.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            bottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            bottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }

    // MARK: - Actions
    @objc private func didTapBookmark() {
        guard let post else { return }
        saved.toggle()
        onSaveTap?(post, saved)
    }

    @objc private func didTapShare() {
        guard let post else { return }
        onShareTap?(post)
    }

    private func updateBookmarkIcon() {
        let name = saved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: name), for: .normal)
    }

    // MARK: - Helpers
    private func formatScore(_ value: Int) -> String {
        if value >= 1_000_000 { return String(format: "%.1fm", Double(value)/1_000_000) }
        if value >= 1_000 { return String(format: "%.1fk", Double(value)/1_000) }
        return "\(value)"
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        let hours = seconds / 3600
        if hours > 0 { return "\(hours)h" }
        let minutes = seconds / 60
        if minutes > 0 { return "\(minutes)m" }
        return "now"
    }
}
