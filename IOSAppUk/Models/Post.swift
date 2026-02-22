//
//  Post.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

struct Post: Codable, Equatable, Hashable {
    let id: String
    let username: String
    let domain: String
    let createdAt: TimeInterval
    let title: String
    let imageURLString: String?
    let rating: Int
    let numComments: Int
    var isSaved: Bool
    let urlString: String?

    var createdDate: Date { Date(timeIntervalSince1970: createdAt) }
    var imageURL: URL? { imageURLString.flatMap(URL.init(string:)) }
    var url: URL? { urlString.flatMap(URL.init(string:)) }
}

extension Post {
    init(api: PostDTO) {
        self.init(api: api, isSaved: Bool.random())
    }
    init(api: PostDTO, isSaved: Bool) {
        self.id = api.id
        self.username = "u/\(api.username)"
        self.domain = api.domain
        self.createdAt = api.createdAt
        self.title = api.title
        self.imageURLString = api.imageURL
        self.rating = api.ups + api.downs
        self.numComments = api.comments.count
        self.isSaved = isSaved
        self.urlString = "http://127.0.0.1:8080/posts/\(api.id)"
    }
}
