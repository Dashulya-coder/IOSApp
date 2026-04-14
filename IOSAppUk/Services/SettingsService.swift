//
//  SettingsService.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import Foundation

final class SettingsService {
    static let shared = SettingsService()

    private let userDefaults = UserDefaults.standard
    private let authorNameKey = "author_name_key"

    private init() {}

    var authorName: String {
        get {
            userDefaults.string(forKey: authorNameKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: authorNameKey)
        }
    }
}
