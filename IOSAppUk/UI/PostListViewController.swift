//
//  PostListViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//

import UIKit

final class PostListViewController: UITableViewController {

    private let service = LabedditService()

    private var posts: [Post] = []
    private var afterCursor: String? = nil
    private var isLoading = false
    private let pageSize = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseId)

        navigationItem.title = "r/ios"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )

        loadNextPage(reset: true)
    }

    @objc private func didTapFilter() {
       
    }

    private func loadNextPage(reset: Bool) {
        guard !isLoading else { return }
        isLoading = true

        let cursorToUse = reset ? nil : afterCursor

        service.fetchPosts(limit: pageSize, after: cursorToUse) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let payload):
                    if reset { self.posts.removeAll() }
                    self.posts.append(contentsOf: payload.posts)
                    self.afterCursor = payload.after
                    self.tableView.reloadData()

                case .failure(let error):
                    print(" fetchPosts error:", error)
                }
            }
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseId, for: indexPath) as! PostTableViewCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = PostDetailsViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Paging
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height


        if offsetY > contentHeight - frameHeight * 1.5 {
            if afterCursor != nil {
                loadNextPage(reset: false)
            }
        }
    }
}
