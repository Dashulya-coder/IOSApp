//
//  LabedditService.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 10.02.2026.
//

import Foundation

final class LabedditService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func fetchPosts(
        limit: Int = 10,
        after: String? = nil,
        completion: @escaping (Result<(posts: [Post], after: String?), Error>) -> Void
    ) {
        let endpoint = Endpoint.posts(limit: limit, after: after)

        client.request(endpoint: endpoint, responseType: ListingResponseDTO.self) { result in
            switch result {
            case .success(let response):
                let posts = response.posts.map { Post(api: $0) }
                completion(.success((posts: posts, after: response.after)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
