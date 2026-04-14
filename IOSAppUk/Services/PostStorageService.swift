//
//  PostStorageService.swift
//  UksheIOSApp
//
//  Created by Daria Ukshe on 14.04.2026.
//

import Foundation
import UIKit

final class PostStorageService {
    static let shared = PostStorageService()

    private let fileManager = FileManager.default
    private let postsFileName = "posts.json"
    private let imagesFolderName = "PostImages"

    private init() {}

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var postsFileURL: URL {
        documentsURL.appendingPathComponent(postsFileName)
    }

    private var imagesFolderURL: URL {
        documentsURL.appendingPathComponent(imagesFolderName)
    }

    func loadPosts() -> [Post] {
        do {
            let data = try Data(contentsOf: postsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Post].self, from: data)
        } catch {
            return []
        }
    }

    func savePosts(_ posts: [Post]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(posts)
        try data.write(to: postsFileURL, options: .atomic)
    }

    func addPost(title: String, text: String, authorName: String, selectedImageURL: URL?) throws -> Post {
        var imageFileName: String?

        if let selectedImageURL {
            imageFileName = try saveImageToDocuments(from: selectedImageURL)
        }

        let newPost = Post(
            title: title,
            text: text,
            authorName: authorName,
            imageFileName: imageFileName,
            isSaved: true
        )

        var posts = loadPosts()
        posts.insert(newPost, at: 0)
        try savePosts(posts)

        return newPost
    }

    func deletePost(id: UUID) throws {
        var posts = loadPosts()

        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        let post = posts[index]

        if let imageFileName = post.imageFileName {
            let imageURL = imagesFolderURL.appendingPathComponent(imageFileName)
            if fileManager.fileExists(atPath: imageURL.path) {
                try? fileManager.removeItem(at: imageURL)
            }
        }

        posts.remove(at: index)
        try savePosts(posts)
    }

    func imageURL(for fileName: String) -> URL {
        imagesFolderURL.appendingPathComponent(fileName)
    }

    private func createImagesFolderIfNeeded() throws {
        if !fileManager.fileExists(atPath: imagesFolderURL.path) {
            try fileManager.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true)
        }
    }

    private func saveImageToDocuments(from sourceURL: URL) throws -> String {
        try createImagesFolderIfNeeded()

        let fileExtension = sourceURL.pathExtension.isEmpty ? "jpg" : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let destinationURL = imagesFolderURL.appendingPathComponent(fileName)

        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: sourceURL)
        try data.write(to: destinationURL, options: .atomic)

        return fileName
    }
}
