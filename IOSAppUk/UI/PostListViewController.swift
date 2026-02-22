//
//  PostListViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//
import UIKit

final class PostListViewController: UITableViewController {

    private let service = LabedditService()

    private var allPosts: [Post] = []
    private var displayedPosts: [Post] = []

    private var afterCursor: String? = nil
    private var isLoading = false
    private let pageSize = 10

    private var isShowingSavedOnly = false
    private let searchController = UISearchController(searchResultsController: nil)

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
            action: #selector(didTapSavedMode)
        )
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search saved posts"
        definesPresentationContext = true

        loadNextPage(reset: true)
    }

    // MARK: - Actions

    @objc private func didTapSavedMode() {
        isShowingSavedOnly.toggle()

        let icon = isShowingSavedOnly ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: icon)

        if !isShowingSavedOnly {
            searchController.searchBar.text = nil
        }

        reloadDataSource()
    }

    // MARK: - Networking / Paging

    private func loadNextPage(reset: Bool) {
        guard !isLoading else { return }
        guard !isShowingSavedOnly else { return }

        isLoading = true
        let cursorToUse = reset ? nil : afterCursor

        service.fetchPosts(limit: pageSize, after: cursorToUse) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let payload):
                    if reset {
                        self.allPosts.removeAll()
                        self.afterCursor = nil
                    }

                    self.allPosts.append(contentsOf: payload.posts)
                    self.afterCursor = payload.after
                    self.reloadDataSource()

                case .failure(let error):
                    print("fetchPosts error:", error)
                }
            }
        }
    }

    // MARK: - Data source refresh

    private func reloadDataSource() {
        if isShowingSavedOnly {
            let saved = SavedPostsStore.shared.allSavedPosts()

            let q = (searchController.searchBar.text ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if q.isEmpty {
                displayedPosts = saved
            } else {
                displayedPosts = saved.filter { $0.title.localizedCaseInsensitiveContains(q) }
            }

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            displayedPosts = allPosts
            navigationItem.searchController = nil
        }

        tableView.reloadData()
    }

    // MARK: - Save / Share handlers

    private func handleSaveToggle(post: Post, newIsSaved: Bool) {
        if newIsSaved {
            var p = post
            p.isSaved = true
            SavedPostsStore.shared.save(p)
        } else {
            SavedPostsStore.shared.remove(id: post.id)
        }
        if let i = allPosts.firstIndex(where: { $0.id == post.id }) {
            allPosts[i].isSaved = newIsSaved
        }
        reloadDataSource()
    }

    private func presentShare(for post: Post) {
        var items: [Any] = [post.title]

        if let url = post.url {
            items.append(url)
        } else if let urlString = post.urlString, let url = URL(string: urlString) {
            items.append(url)
        }

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseId, for: indexPath) as! PostTableViewCell

        let post = displayedPosts[indexPath.row]
        cell.configure(with: post)
        cell.onSaveTap = { [weak self] post, newIsSaved in
            self?.handleSaveToggle(post: post, newIsSaved: newIsSaved)
        }
        cell.onShareTap = { [weak self] post in
            self?.presentShare(for: post)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = displayedPosts[indexPath.row]
        let vc = PostDetailsViewController(post: post)
        vc.onPostUpdated = { [weak self] updated in
            guard let self else { return }

            if updated.isSaved {
                SavedPostsStore.shared.save(updated)
            } else {
                SavedPostsStore.shared.remove(id: updated.id)
            }

            if let i = self.allPosts.firstIndex(where: { $0.id == updated.id }) {
                self.allPosts[i] = updated
            }

            self.reloadDataSource()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Paging trigger

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isShowingSavedOnly else { return }
        guard !isLoading else { return }
        guard afterCursor != nil else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 1.5 {
            loadNextPage(reset: false)
        }
    }
}

    // MARK: - UISearchResultsUpdating
    extension PostListViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            guard isShowingSavedOnly else { return }
            reloadDataSource()
        }
    }
