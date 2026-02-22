//
//  Endpoint.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

enum Endpoint {
    case posts(limit: Int, after: String?)
}

extension Endpoint {
    var baseURL: URL {
        URL(string: "http://127.0.0.1:8080")!
    }

    var path: String {
        switch self {
        case .posts:
            return "/posts"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .posts(let limit, let after):
            var items = [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            if let after {
                items.append(URLQueryItem(name: "after", value: after))
            }
            return items
        }
    }

    var urlRequest: URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path),
                                        resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return request
    }
}
