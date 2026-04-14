//
//  PostsListViewModel.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import Foundation
import Combine

final class PostsListViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []

    private let storageService: PostStorageService

    init(storageService: PostStorageService = .shared) {
        self.storageService = storageService
        loadPosts()
    }

    func loadPosts() {
        posts = storageService.loadPosts()
    }

    func imageURL(for post: Post) -> URL? {
        guard let imageFileName = post.imageFileName else { return nil }
        return storageService.imageURL(for: imageFileName)
    }
}
