//
//  Post.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

struct Post {
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
    init(api: LabedditPostDTO) {
        self.username = "u/\(api.username)"
        self.domain = api.domain
        self.created = Date(timeIntervalSince1970: api.createdAt)
        self.title = api.title

        self.imageURL = URL(string: api.imageURL ?? "")

        self.rating = api.ups + api.downs
        self.numComments = api.comments?.count ?? 0

        self.saved = Bool.random()
    }
}
