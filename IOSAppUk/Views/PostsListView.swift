//
//  PostsListView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI
import UIKit

struct PostsListView: View {
    @StateObject private var viewModel = PostsListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.15), .purple.opacity(0.10), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    if viewModel.posts.isEmpty {
                        emptyPlaceholder
                    } else {
                        postsContent
                    }
                }
                .padding()
            }
            .navigationTitle("Local posts")
            .onAppear {
                viewModel.loadPosts()
            }
        }
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.image")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("No local posts yet")
                .font(.title2.bold())

            Text("Create your first post on the Create tab")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var postsContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    LocalPostCardView(
                        post: post,
                        imageURL: viewModel.imageURL(for: post)
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
}
