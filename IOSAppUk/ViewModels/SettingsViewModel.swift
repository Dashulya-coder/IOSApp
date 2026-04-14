//
//  SettingsViewModel.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var authorName: String = ""

    private let settingsService: SettingsService

    init(settingsService: SettingsService = .shared) {
        self.settingsService = settingsService
        self.authorName = settingsService.authorName
    }

    func saveAuthorName() {
        settingsService.authorName = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        authorName = settingsService.authorName
    }
}
