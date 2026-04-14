//
//  RedditListContainerView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI
import UIKit

struct RedditListContainerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = PostListViewController()
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
