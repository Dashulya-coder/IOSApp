//
//  PostViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import UIKit
import Kingfisher

final class PostViewController: UIViewController {

    private let service = LabedditService()
    private var currentPost: Post?

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        setupLayout()

        // Initial state (optional)
        headerLabel.text = "Loading…"
        titleLabel.text = nil
        ratingLabel.text = nil
        commentsLabel.text = nil
        postImageView.image = nil
        updateBookmarkIcon()

        loadPost()
    }

    // MARK: - Networking
    private func loadPost() {
        service.fetchPosts(limit: 1, after: nil) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let payload):
                    // payload.posts = [Post], payload.after = String?
                    guard let post = payload.posts.first else {
                        self.showErrorUI(message: "No posts returned.")
                        return
                    }
                    self.currentPost = post
                    self.render(post: post)

                    // якщо треба — можна зберегти after для пагінації:
                    // self.afterCursor = payload.after

                case .failure(let error):
                    self.showErrorUI(message: error.localizedDescription)
                }
            }
        }
    }

    private func showErrorUI(message: String) {
        headerLabel.text = "Failed to load post"
        titleLabel.text = message
        ratingLabel.text = nil
        commentsLabel.text = nil
        postImageView.image = UIImage(systemName: "exclamationmark.triangle")
        updateBookmarkIcon()
    }
    
    // MARK: - Render
    private func render(post: Post) {
        headerLabel.text = "\(post.username) • \(timeAgo(from: post.created)) • \(post.domain)"
        titleLabel.text = post.title
        ratingLabel.text = "↑ \(formatScore(post.rating))"
        commentsLabel.text = "💬 \(post.numComments)"

        updateBookmarkIcon()

        if let url = post.imageURL {
            postImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.25)),
                    .cacheOriginalImage
                ]
            )
        } else {
            postImageView.image = UIImage(systemName: "photo")
        }
    }

    // MARK: - Helpers
    private func formatScore(_ value: Int) -> String {
        if value >= 1_000_000 { return String(format: "%.1fm", Double(value) / 1_000_000) }
        if value >= 1_000 { return String(format: "%.1fk", Double(value) / 1_000) }
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

    // MARK: - Setup UI
    private func setupUI() {
        // Card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        view.addSubview(cardView)

        // Header label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.numberOfLines = 1
        cardView.addSubview(headerLabel)

        // Bookmark button
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.tintColor = .label
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        cardView.addSubview(bookmarkButton)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)

        // Image
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .tertiarySystemFill
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        cardView.addSubview(postImageView)

        // Bottom bar
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
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Card centered, adaptive width
            cardView.centerYAnchor.constraint(equalTo: safe.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),

            // Header
            headerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: bookmarkButton.leadingAnchor, constant: -8),

            bookmarkButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 28),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 28),

            // Title
            titleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Image
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 300),

            // Bottom bar
            bottomBar.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            bottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            bottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            // So card won’t become too tall
            cardView.heightAnchor.constraint(lessThanOrEqualTo: safe.heightAnchor, multiplier: 0.85)
        ])
    }

    // MARK: - Actions
    @objc private func didTapBookmark() {
        guard var post = currentPost else { return }
        post.saved.toggle()
        currentPost = post
        updateBookmarkIcon()
    }

    @objc private func didTapShare() {
        guard let post = currentPost else { return }

        // Share text + link (if image url exists, we can share it too)
        var items: [Any] = [post.title]
        if let url = post.imageURL {
            items.append(url)
        }

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }

    private func updateBookmarkIcon() {
        let isSaved = currentPost?.saved ?? false
        let name = isSaved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: name), for: .normal)
    }
}
