//
//  LabedditDTO.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 17.02.2026.
//

import Foundation

// MARK: - Labeddit response
struct ListingResponseDTO: Decodable {
    let after: String?
    let posts: [PostDTO]
}

struct PostDTO: Decodable {
    let id: String
    let username: String
    let domain: String
    let createdAt: TimeInterval
    let title: String
    let imageURL: String?
    let ups: Int
    let downs: Int
    let comments: [CommentDTO]

    enum CodingKeys: String, CodingKey {
        case id, username, domain, title, ups, downs, comments
        case createdAt = "created_at"
        case imageURL = "image_url"
    }
}

struct CommentDTO: Decodable {
    let id: String
    let username: String
    let text: String
    let ups: Int
    let downs: Int
    let postID: String

    enum CodingKeys: String, CodingKey {
        case id, username, text, ups, downs
        case postID = "post_id"
    }
}
