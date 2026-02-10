//
//  LabedditModels.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

// MARK: - Response
struct LabedditPostsResponse: Codable {
    let after: String?
    let posts: [LabedditPostDTO]
}

// MARK: - Post DTO (from API)
struct LabedditPostDTO: Codable {
    let id: String
    let domain: String
    let createdAt: TimeInterval
    let text: String?
    let imageURL: String?
    let downs: Int
    let ups: Int
    let username: String
    let title: String
    let comments: [LabedditCommentDTO]?

    enum CodingKeys: String, CodingKey {
        case id, domain, text, downs, ups, username, title, comments
        case createdAt = "created_at"
        case imageURL = "image_url"
    }
}

struct LabedditCommentDTO: Codable {
    let username: String
    let id: String
    let text: String
    let ups: Int
    let downs: Int
    let postID: String

    enum CodingKeys: String, CodingKey {
        case username, id, text, ups, downs
        case postID = "post_id"
    }
}
