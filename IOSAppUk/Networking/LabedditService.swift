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
        limit: Int = 1,
        after: String? = nil,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let endpoint = Endpoint.posts(limit: limit, after: after)

        client.request(endpoint: endpoint, responseType: ListingResponse.self) { result in
            switch result {
            case .success(let listing):
                let posts = listing.data.children.map { Post(api: $0.data) }
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
