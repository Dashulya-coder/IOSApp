//
//  LocalPostCardView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI
import UIKit

struct LocalPostCardView: View {
    let post: Post
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageURL,
               let uiImage = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            Text(post.title)
                .font(.title3.bold())

            Text(post.text)
                .font(.body)
                .foregroundStyle(.primary)

            HStack {
                Text("Author: \(post.authorName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
