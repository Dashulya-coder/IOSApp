//
//  SavedPostsStore.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 21.02.2026.
//

import Foundation

final class SavedPostsStore {
    static let shared = SavedPostsStore()

    private init() {
        loadFromDisk()
    }

    private var savedById: [String: RedditPost] = [:]

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("saved_posts.json")
    }

    func isSaved(id: String) -> Bool {
        savedById[id] != nil
    }

    func allSavedPosts() -> [RedditPost] {
        savedById.values.sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ post: RedditPost) {
        var updated = post
        updated.isSaved = true
        savedById[updated.id] = updated
        persistToDisk()
    }

    func remove(id: String) {
        savedById.removeValue(forKey: id)
        persistToDisk()
    }

    func toggle(post: RedditPost) -> Bool {
        if isSaved(id: post.id) {
            remove(id: post.id)
            return false
        } else {
            save(post)
            return true
        }
    }

    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([String: RedditPost].self, from: data)
            self.savedById = decoded
        } catch {
            self.savedById = [:]
        }
    }

    private func persistToDisk() {
        do {
            let data = try JSONEncoder().encode(savedById)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("SavedPostsStore persist error:", error)
        }
    }
}
