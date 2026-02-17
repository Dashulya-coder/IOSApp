//
//  PostTableViewCell.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//

import UIKit

final class PostTableViewCell: UITableViewCell {

    static let reuseId = "PostTableViewCell"

    private let postView = PostView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        postView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(postView)

        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            postView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with post: Post) {
        postView.configure(with: post)
    }
}
