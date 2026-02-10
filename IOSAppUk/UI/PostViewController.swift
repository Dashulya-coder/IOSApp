//
//  PostViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation
import UIKit

final class PostViewController: UIViewController {

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

    // тимчасово (поки немає API)
    private var saved = Bool.random() {
        didSet { updateBookmarkIcon() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupLayout()
        fillFakeData()
    }

    // MARK: - Setup
    private func setupUI() {
        // card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        view.addSubview(cardView)

        // header label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.numberOfLines = 1
        cardView.addSubview(headerLabel)

        // bookmark
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.tintColor = .label
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        cardView.addSubview(bookmarkButton)
        updateBookmarkIcon()

        // title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)

        // image
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .tertiarySystemFill
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        cardView.addSubview(postImageView)

        // bottom bar
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
        
        
        bottomBar.addArrangedSubview(ratingLabel)
        bottomBar.addArrangedSubview(commentsLabel)
        bottomBar.addArrangedSubview(shareButton)
    }

    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // card centered, adaptive width
            cardView.centerYAnchor.constraint(equalTo: safe.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),

            // header
            headerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: bookmarkButton.leadingAnchor, constant: -8),

            bookmarkButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 28),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 28),

            // title
            titleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // image
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 300),

            // bottom bar
            bottomBar.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            bottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            bottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            // щоб card не ставав занадто високим
            cardView.heightAnchor.constraint(lessThanOrEqualTo: safe.heightAnchor, multiplier: 0.85)
        ])
    }

    private func fillFakeData() {
        headerLabel.text = "u/Notdovvn • 15h • i.redd.it"
        titleLabel.text = "Anyone else think this should show the battery percentage of all of your devices?"
        ratingLabel.text = "↑ 1.0k"
        commentsLabel.text = "💬 85"
        // картинку поки не вантажимо — сірий плейсхолдер
    }

    // MARK: - Actions
    @objc private func didTapBookmark() {
        saved.toggle()
    }

    private func updateBookmarkIcon() {
        let name = saved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: name), for: .normal)
    }
}
