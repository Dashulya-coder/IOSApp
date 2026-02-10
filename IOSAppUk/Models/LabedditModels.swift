//
//  LabedditModels.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

// MARK: - Top level
struct ListingResponse: Codable {
    let data: ListingData
}

struct ListingData: Codable {
    let children: [ListingChild]
    let after: String?
}

struct ListingChild: Codable {
    let data: ListingPostData
}

// MARK: - Post data from API
struct ListingPostData: Codable {
    let author: String
    let domain: String?
    let title: String
    let createdUtc: TimeInterval

    // image/url fields (у різних постів може бути по-різному)
    let url: String?
    let urlOverriddenByDest: String?

    // counters
    let ups: Int?
    let downs: Int?
    let numComments: Int?

    // потрібно для пагінації "after" (на майбутнє)
    let name: String?

    enum CodingKeys: String, CodingKey {
        case author, domain, title, url, ups, downs, name
        case createdUtc = "created_utc"
        case numComments = "num_comments"
        case urlOverriddenByDest = "url_overridden_by_dest"
    }
}
