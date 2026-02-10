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
    init(api: ListingPostData) {
        self.username = "u/\(api.author)"
        self.domain = api.domain ?? ""

        self.created = Date(timeIntervalSince1970: api.createdUtc)

        self.title = api.title

        // пріоритет: url_overridden_by_dest, якщо нема — url
        let urlString = api.urlOverriddenByDest ?? api.url
        self.imageURL = URL(string: urlString ?? "")

        let ups = api.ups ?? 0
        let downs = api.downs ?? 0
        self.rating = ups + downs

        self.numComments = api.numComments ?? 0

        self.saved = Bool.random()
    }
}
