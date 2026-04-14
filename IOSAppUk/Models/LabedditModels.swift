//
//  LabedditModels.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

struct RedditPost: Codable, Equatable, Identifiable {
    let id: String
    let username: String
    let domain: String
    let createdAt: TimeInterval
    let title: String
    let imageURLString: String?
    let ups: Int
    let downs: Int
    let commentsCount: Int
    let urlString: String?
    var isSaved: Bool

    var createdDate: Date {
        Date(timeIntervalSince1970: createdAt)
    }

    var rating: Int {
        ups - downs
    }

    var numComments: Int {
        commentsCount
    }

    var imageURL: URL? {
        guard let imageURLString else { return nil }
        return URL(string: imageURLString)
    }

    var url: URL? {
        guard let urlString else { return nil }
        return URL(string: urlString)
    }
}

enum FeedItem: Identifiable, Equatable {
    case reddit(RedditPost)
    case local(Post)

    var id: String {
        switch self {
        case .reddit(let post):
            return "reddit_\(post.id)"
        case .local(let post):
            return "local_\(post.id.uuidString)"
        }
    }

    var titleForSearch: String {
        switch self {
        case .reddit(let post):
            return post.title
        case .local(let post):
            return post.title
        }
    }
}

