//
//  LocalPostTableViewCell.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import UIKit
import SwiftUI

final class LocalPostTableViewCell: UITableViewCell {
    static let reuseId = "LocalPostTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(post: Post, imageURL: URL?) {
        contentConfiguration = UIHostingConfiguration {
            LocalPostCardView(post: post, imageURL: imageURL)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .margins(.all, 0)
    }
}
