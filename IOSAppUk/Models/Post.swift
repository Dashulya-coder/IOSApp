//
//  Post.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

struct Post: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let text: String
    let authorName: String
    let imageFileName: String?
    let createdAt: Date
    var isSaved: Bool

    init(
        id: UUID = UUID(),
        title: String,
        text: String,
        authorName: String,
        imageFileName: String? = nil,
        createdAt: Date = Date(),
        isSaved: Bool = true
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.authorName = authorName
        self.imageFileName = imageFileName
        self.createdAt = createdAt
        self.isSaved = isSaved
    }
}
