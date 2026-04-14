//
//  PostListViewController.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//
import UIKit

final class PostListViewController: UITableViewController {

    private let service = LabedditService()
    private let localStorage = PostStorageService.shared

    private var redditPosts: [RedditPost] = []
    private var displayedItems: [FeedItem] = []

    private var afterCursor: String?
    private var isLoading = false
    private let pageSize = 10

    private var isShowingSavedOnly = false
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .none

        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseId)
        tableView.register(LocalPostTableViewCell.self, forCellReuseIdentifier: LocalPostTableViewCell.reuseId)

        navigationItem.title = "Posts"
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocalPostsChanged),
            name: .localPostsDidChange,
            object: nil
        )

        loadNextPage(reset: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleLocalPostsChanged() {
        reloadDataSource()
    }

    @objc private func didTapSavedMode() {
        isShowingSavedOnly.toggle()

        let icon = isShowingSavedOnly ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: icon)

        if !isShowingSavedOnly {
            searchController.searchBar.text = nil
        }

        reloadDataSource()
    }

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
                        self.redditPosts.removeAll()
                        self.afterCursor = nil
                    }

                    self.redditPosts.append(contentsOf: payload.posts)
                    self.afterCursor = payload.after
                    self.reloadDataSource()

                case .failure(let error):
                    print("fetchPosts error:", error)
                }
            }
        }
    }

    private func reloadDataSource() {
        let localPosts = localStorage.loadPosts()

        if isShowingSavedOnly {
            let savedReddit = SavedPostsStore.shared.allSavedPosts().map { FeedItem.reddit($0) }
            let savedLocal = localPosts.map { FeedItem.local($0) }
            let allSaved = savedLocal + savedReddit

            let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            if query.isEmpty {
                displayedItems = allSaved
            } else {
                displayedItems = allSaved.filter {
                    $0.titleForSearch.localizedCaseInsensitiveContains(query)
                }
            }

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            let localItems = localPosts.map { FeedItem.local($0) }
            let redditItems = redditPosts.map { FeedItem.reddit($0) }
            displayedItems = localItems + redditItems
            navigationItem.searchController = nil
        }

        tableView.reloadData()
    }

    private func handleRedditSaveToggle(post: RedditPost, newIsSaved: Bool) {
        var updated = post
        updated.isSaved = newIsSaved

        if newIsSaved {
            SavedPostsStore.shared.save(updated)
        } else {
            SavedPostsStore.shared.remove(id: updated.id)
        }

        if let index = redditPosts.firstIndex(where: { $0.id == post.id }) {
            redditPosts[index] = updated
        }

        reloadDataSource()
    }

    private func deleteLocalPost(_ post: Post) {
        do {
            try localStorage.deletePost(id: post.id)
            NotificationCenter.default.post(name: .localPostsDidChange, object: nil)
            reloadDataSource()
        } catch {
            print("Delete local post error:", error)
        }
    }

    private func presentShare(for post: RedditPost) {
        var items: [Any] = [post.title]

        if let url = post.url {
            items.append(url)
        }

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayedItems[indexPath.row]

        switch item {
        case .reddit(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseId, for: indexPath) as! PostTableViewCell
            cell.configure(with: post)
            cell.onSaveTap = { [weak self] post, newIsSaved in
                self?.handleRedditSaveToggle(post: post, newIsSaved: newIsSaved)
            }
            cell.onShareTap = { [weak self] post in
                self?.presentShare(for: post)
            }
            return cell

        case .local(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: LocalPostTableViewCell.reuseId, for: indexPath) as! LocalPostTableViewCell
            let imageURL = post.imageFileName.map { localStorage.imageURL(for: $0) }
            cell.configure(post: post, imageURL: imageURL)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = displayedItems[indexPath.row]

        switch item {
        case .reddit(let post):
            let vc = PostDetailsViewController(post: post)
            vc.onPostUpdated = { [weak self] updated in
                guard let self else { return }

                if updated.isSaved {
                    SavedPostsStore.shared.save(updated)
                } else {
                    SavedPostsStore.shared.remove(id: updated.id)
                }

                if let i = self.redditPosts.firstIndex(where: { $0.id == updated.id }) {
                    self.redditPosts[i] = updated
                }

                self.reloadDataSource()
            }
            navigationController?.pushViewController(vc, animated: true)

        case .local(let post):
            guard isShowingSavedOnly else { return }

            let alert = UIAlertController(
                title: "Delete post?",
                message: "Local post will be removed completely.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deleteLocalPost(post)
            })

            present(alert, animated: true)
        }
    }

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

extension PostListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard isShowingSavedOnly else { return }
        reloadDataSource()
    }
}
