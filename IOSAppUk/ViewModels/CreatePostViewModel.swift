//
//  CreatePostViewModel.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import Foundation
import Combine

final class CreatePostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var text: String = ""
    @Published var selectedImageURL: URL?

    @Published var showMissingAuthorAlert = false
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var didCreatePost = false

    private let storageService: PostStorageService
    private let settingsService: SettingsService

    init(
        storageService: PostStorageService = .shared,
        settingsService: SettingsService = .shared
    ) {
        self.storageService = storageService
        self.settingsService = settingsService
    }

    var authorName: String {
        settingsService.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasAuthorName: Bool {
        !authorName.isEmpty
    }

    func checkAuthorBeforeEnteringScreen() {
        if !hasAuthorName {
            showMissingAuthorAlert = true
        }
    }

    func createPost(onSuccess: () -> Void) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard hasAuthorName else {
            showMissingAuthorAlert = true
            return
        }

        guard !trimmedTitle.isEmpty else {
            validationMessage = "Введіть заголовок поста."
            showValidationAlert = true
            return
        }

        guard !trimmedText.isEmpty else {
            validationMessage = "Введіть основний текст поста."
            showValidationAlert = true
            return
        }

        do {
            _ = try storageService.addPost(
                title: trimmedTitle,
                text: trimmedText,
                authorName: authorName,
                selectedImageURL: selectedImageURL
            )

            NotificationCenter.default.post(name: .localPostsDidChange, object: nil)

            title = ""
            text = ""
            selectedImageURL = nil
            didCreatePost = true
            onSuccess()
        } catch {
            validationMessage = "Не вдалося зберегти пост."
            showValidationAlert = true
        }
    }
}
