//
//  PostDetailsViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//
import UIKit

final class PostDetailsViewController: UIViewController {

    private var post: Post
    private let postView = PostView()

    var onPostUpdated: ((Post) -> Void)?

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        title = ""
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
        post.isSaved = SavedPostsStore.shared.isSaved(id: post.id)

        postView.configure(with: post)
        postView.onSaveTap = { [weak self] tappedPost, newIsSaved in
            guard let self else { return }

            var updated = tappedPost
            updated.isSaved = newIsSaved

            if newIsSaved {
                SavedPostsStore.shared.save(updated)
            } else {
                SavedPostsStore.shared.remove(id: updated.id)
            }

            self.post = updated
            self.postView.configure(with: updated)
            self.onPostUpdated?(updated)
        }
        postView.onShareTap = { [weak self] post in
            guard let self else { return }

            var items: [Any] = [post.title]

            if let url = post.url {
                items.append(url)
            } else if let urlString = post.urlString, let url = URL(string: urlString) {
                items.append(url)
            }

            let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(vc, animated: true)
        }
    }
}
