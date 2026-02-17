//
//  Post.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

struct Post {
    let id: String
    let username: String
    let domain: String
    let created: Date
    let title: String
    let imageURL: URL?
    let rating: Int
    let numComments: Int
    var saved: Bool
}

extension Post {
    init(api: PostDTO) {
        self.id = api.id
        self.username = "u/\(api.username)"
        self.domain = api.domain
        self.created = Date(timeIntervalSince1970: api.createdAt)
        self.title = api.title
        self.imageURL = api.imageURL.flatMap(URL.init(string:))
        self.rating = api.ups + api.downs        // як у твоєму скріні
        self.numComments = api.comments.count
        self.saved = Bool.random()
    }
}
