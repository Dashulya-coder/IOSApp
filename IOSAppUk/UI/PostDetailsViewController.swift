//
//  PostDetailsViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//

import UIKit

final class PostDetailsViewController: UIViewController {

    private let post: Post
    private let postView = PostView()

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        title = "" // хай буде чисто, back button системний
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        postView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postView)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            postView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            postView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16)
        ])

        postView.configure(with: post)
    }
}
