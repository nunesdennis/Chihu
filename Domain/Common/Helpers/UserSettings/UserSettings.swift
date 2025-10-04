//
//  UserSettings.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/09/24.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    enum Constants: String {
        case accessTokenKey = "userAccessToken"
        case instanceURL
        case tip
        case theme
        case neoDBScore
        case yourScore
        case defaultShelfType
        case defaultSearchCategory
    }
    
    private let userDefaultsAppGroup = UserDefaults(suiteName: "group.nunesdennis.chihu")
    static let shared = UserSettings()
    
    var instanceURL: String?
    var accessToken: String?
    var fullUsername: String?
    
    var colorScheme: ColorScheme {
        switch selectedTheme {
        case .lightModeDefault:
                .light
        case .darkModeDefault:
                .dark
        }
    }
    
    @Environment(\.colorScheme) static var appColorScheme
    @Published var language: Language = .en(region: .standard(code: "US"))
    @Published var userPreference: UserPreference.Load.ViewModel?
    @Published var selectedTheme: Theme
    @Published var shouldShowLogin: Bool
    
    @Published var shouldHideTip: Bool {
        didSet {
            saveIgnoreTip(shouldIgnore: shouldHideTip)
        }
    }
    
    @Published var defaultShelfType: String {
        didSet {
            saveDefaultShelfType(defaultShelfType)
        }
    }
    
    @Published var defaultSearchCategory: String {
        didSet {
            saveDefaultSearchCategory(defaultSearchCategory)
        }
    }
    
    @Published var showNeoDBscore: Bool {
        didSet {
            saveHideShowNeoDBscore(shouldShow: showNeoDBscore)
        }
    }
    
    @Published var showYourScore: Bool {
        didSet {
            saveHideShowYourScore(shouldShow: showYourScore)
        }
    }
    
    @Published var profileInfo: Profile.Load.ViewModel?
    
    private init() {
        language = UserSettings.getLanguage()
        instanceURL = userDefaultsAppGroup?.string(forKey: Constants.instanceURL.rawValue)
        accessToken = KeychainManager.instance.getToken(forKey: Constants.accessTokenKey.rawValue)
        shouldShowLogin = accessToken == nil || instanceURL == nil
        shouldHideTip = userDefaultsAppGroup?.bool(forKey: Constants.tip.rawValue) ?? false
        showYourScore = userDefaultsAppGroup?.bool(forKey: Constants.yourScore.rawValue) ?? true
        showNeoDBscore = userDefaultsAppGroup?.bool(forKey: Constants.neoDBScore.rawValue) ?? true
        defaultShelfType = userDefaultsAppGroup?.string(forKey: Constants.defaultShelfType.rawValue) ?? ShelfType.progress.rawValue
        defaultSearchCategory = userDefaultsAppGroup?.string(forKey: Constants.defaultSearchCategory.rawValue) ?? ItemCategory.movie.rawValue
        
        selectedTheme = UserSettings.getTheme()
        if !shouldShowLogin {
            fetchUserPreference()
            fetchProfile()
        }
    }
    
    func fetchProfile() {
        let worker = ProfileNetworkingWorker()
        Task(priority: .background) {
            worker.fetchUser(request: Profile.Load.Request()) { [unowned self] result in
                switch result {
                case .success(let response):
                    profileInfo = Profile.Load.ViewModel(user: response.user)
                    fullUsername = setFullUsername()
                case .failure:
                    // no-op
                    return
                }
            }
        }
    }
    
    func setFullUsername() -> String? {
        guard let baseUrlString = instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines),
              let baseUrl = URL(string: baseUrlString),
              let username = profileInfo?.username else {
            return nil
        }
        let baseUrlName = UrlCleaner.keepSiteName(from: baseUrl)
        return username + "@" + baseUrlName
    }
    
    func fetchUserPreference() {
        let worker = UserNetworkingWorker()
        Task(priority: .background) {
            worker.fetchUserPreference(request: .init()) { [unowned self] result in
                switch result {
                case .success(let response):
                    userPreference = UserPreference.Load.ViewModel(preference: response.userPreference)
                case .failure:
                    userPreference = UserPreference.Load.ViewModel(defaultCrosspost: true,
                                                                   defaultVisibility: .public,
                                                                   hiddenCategories: [])
                }
            }
        }
    }
    
    func saveToken(_ token: String) throws {
        try KeychainManager.instance.saveToken(token, forKey: Constants.accessTokenKey.rawValue)
        updateUserSettings()
    }
    
    func saveBaseUrl(_ instanceURL: String) {
        userDefaultsAppGroup?.setValue(instanceURL, forKey: Constants.instanceURL.rawValue)
        updateUserSettings()
    }
    
    func saveTheme(_ theme: Theme) {
        userDefaultsAppGroup?.setValue(theme.rawValue, forKey: Constants.theme.rawValue)
        selectedTheme = theme
    }
    
    func logout() throws {
        userPreference = nil
        instanceURL = nil
        accessToken = nil
        profileInfo = nil
        userDefaultsAppGroup?.removeObject(forKey: EnvironmentKeys.Constants.customClientId.rawValue)
        userDefaultsAppGroup?.removeObject(forKey: EnvironmentKeys.Constants.customClientSecret.rawValue)
        userDefaultsAppGroup?.removeObject(forKey: Constants.instanceURL.rawValue)
        clearAllAppStorage()
        try KeychainManager.instance.deleteToken(forKey: Constants.accessTokenKey.rawValue)
        updateUserSettings()
        clearAllAppCache()
    }
    
    func clearAllAppCache() {
        clearOldCacheFiles(olderThan: 1)
        smartClearURLCache(maxDiskSizeInMB: 200)
        clearTemporaryDirectory()
    }
    
    private func clearAllAppStorage() {
        let dictionary = userDefaultsAppGroup?.dictionaryRepresentation()
        dictionary?.keys.forEach { key in
            userDefaultsAppGroup?.removeObject(forKey: key)
        }
        userDefaultsAppGroup?.synchronize()
    }
    
    private func clearOldCacheFiles(olderThan days: Int) {
        let fileManager = FileManager.default
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.contentModificationDateKey])
                for fileURL in fileURLs {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    if let modificationDate = attributes[.modificationDate] as? Date {
                        if Calendar.current.dateComponents([.day], from: modificationDate, to: Date()).day ?? 0 > days {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            } catch {
                print("Erro ao limpar cache antigo: \(error.localizedDescription)")
            }
        }
    }

    private func clearTemporaryDirectory() {
        let tempDirURL = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDirURL, includingPropertiesForKeys: nil)
            for fileURL in tempFiles {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Erro ao limpar tmp: \(error.localizedDescription)")
        }
    }

    private func smartClearURLCache(maxDiskSizeInMB: Int) {
        let cache = URLCache.shared
        let currentDiskUsage = cache.currentDiskUsage // em bytes
        let maxDiskUsage = maxDiskSizeInMB * 1024 * 1024 // converte MB para bytes

        if currentDiskUsage > maxDiskUsage {
            cache.removeAllCachedResponses()
        } else {
            print("✅ Cache OK: \(currentDiskUsage / (1024 * 1024)) MB. Não foi necessário limpar.")
        }
    }
    
    private func updateUserSettings() {
        instanceURL = userDefaultsAppGroup?.string(forKey: Constants.instanceURL.rawValue)
        accessToken = KeychainManager.instance.getToken(forKey: Constants.accessTokenKey.rawValue)
        shouldShowLogin = accessToken == nil || instanceURL == nil
    }
    
    private static func getTheme() -> Theme {
        let appDefaultTheme = appColorScheme == .light ? Theme.lightModeDefault : Theme.darkModeDefault
        if let themeValue = UserDefaults(suiteName: "group.nunesdennis.chihu")?.string(forKey: Constants.theme.rawValue) {
            return Theme(rawValue: themeValue) ?? appDefaultTheme
        } else {
            return appDefaultTheme
        }
    }
    
    private static func getLanguage() -> Language {
        // Using system
        let languageCode = Locale.current.language.languageCode?.identifier
        let regionCode = Locale.current.region?.identifier
        if let languageCode, let regionCode {
            let languageValue = "\(languageCode)-\(regionCode.lowercased())"
            return Language.from(languageValue) ?? .en(region: .standard(code: "US"))
        } else if let languageCode {
            return Language.from(languageCode) ?? .en(region: .standard(code: "US"))
        } else {
            return .en(region: .standard(code: "US"))
        }
    }
    
    private func saveHideShowNeoDBscore(shouldShow: Bool) {
        userDefaultsAppGroup?.setValue(shouldShow, forKey: Constants.neoDBScore.rawValue)
    }
    
    private func saveHideShowYourScore(shouldShow: Bool) {
        userDefaultsAppGroup?.setValue(shouldShow, forKey: Constants.yourScore.rawValue)
    }
    
    private func saveIgnoreTip(shouldIgnore: Bool) {
        userDefaultsAppGroup?.setValue(shouldIgnore, forKey: Constants.tip.rawValue)
    }
    
    private func saveDefaultShelfType(_ defaultShelfType: String) {
        userDefaultsAppGroup?.setValue(defaultShelfType, forKey: Constants.defaultShelfType.rawValue)
    }
    
    private func saveDefaultSearchCategory(_ defaultSearchCategory: String) {
        userDefaultsAppGroup?.setValue(defaultSearchCategory, forKey: Constants.defaultSearchCategory.rawValue)
    }
}
