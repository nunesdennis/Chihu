//
//  Environment.swift
//  Chihu
//
//  Created by Dennis Nunes on 29/10/24.
//

import Foundation

public enum EnvironmentKeys {
    enum Constants: String {
        case customClientId
        case customClientSecret
    }
    
    enum Key: String {
        case tmdbAPIkey = "TMDB_API_KEY"
        case teamId = "TEAM_ID"
        case podcastIndexApiKey = "PODCAST_INDEX_KEY"
        case podcastIndexApiClientSecret = "PODCAST_INDEX_SECRET"
        
        case apiKey = "API_KEY"
        case apiClientId = "API_CLIENT_ID"
        case apiClientSecret = "API_CLIENT_SECRET"
        case neodbApiClientId = "NEODB_SOCIAL_CLIENT_ID"
        case neodbApiClientSecret = "NEODB_SOCIAL_CLIENT_SECRET"
        case reviewdbApiClientId = "REVIEWDB_APP_CLIENT_ID"
        case reviewdbApiClientSecret = "REVIEWDB_APP_CLIENT_SECRET"
        case minreolApiClientId = "MINREOL_DK_CLIENT_ID"
        case minreolApiClientSecret = "MINREOL_DK_CLIENT_SECRET"
        case dbCasuallyApiClientId = "DB_CASUALLY_CAT_CLIENT_ID"
        case dbCasuallyApiClientSecret = "DB_CASUALLY_CAT_CLIENT_SECRET"
        case neodbKevgaApiClientId = "NEODB_KEVGA_DE_CLIENT_ID"
        case neodbKevgaApiClientSecret = "NEODB_KEVGA_DE_CLIENT_SECRET"
        case neodbDeadveyClientId = "NEODB_DEADVEY_COM_CLIENT_ID"
        case neodbDeadveyClientSecret = "NEODB_DEADVEY_COM_CLIENT_SECRET"
        case fantastikaClientId = "FANTASTIKA_SOCIAL_CLIENT_ID"
        case fantastikaClientSecret = "FANTASTIKA_SOCIAL_CLIENT_SECRET"
    }
    
    ///Getting plist here
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found" )
        }
        
        return dict
    }()
    
    static func getApiClientId(from urlString: String) -> EnvironmentKeys.Key {
        var urlString = urlString
        
        urlString = urlString.replacingOccurrences(of: "https://", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: "http://", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: "/", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: ".", with: "_", options: .caseInsensitive)
        urlString = urlString.uppercased()
        
        return Key(rawValue: urlString + "_CLIENT_ID") ?? .apiClientId
    }
    
    static func getApiClientSecret(from urlString: String) -> EnvironmentKeys.Key {
        var urlString = urlString
        
        urlString = urlString.replacingOccurrences(of: "https://", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: "http://", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: "/", with: String(), options: .caseInsensitive)
        urlString = urlString.replacingOccurrences(of: ".", with: "_", options: .caseInsensitive)
        urlString = urlString.uppercased()
        
        return Key(rawValue: urlString + "_CLIENT_SECRET") ?? .apiClientSecret
    }
    
    static func getValueFor(_ key: Key) -> String? {
        guard let value = EnvironmentKeys.infoDictionary[key.rawValue] as? String else {
            fatalError("Value not set in plist")
        }
        
        return value
    }
    
    static func saveCustomKeys(from model: AppRegistrationResponse) {
        UserDefaults(suiteName: "group.nunesdennis.chihu")?.setValue(model.clientId, forKey: Constants.customClientId.rawValue)
        UserDefaults(suiteName: "group.nunesdennis.chihu")?.setValue(model.clientSecret, forKey: Constants.customClientSecret.rawValue)
    }
    
    static func getCustomClientId() -> String? {
        UserDefaults(suiteName: "group.nunesdennis.chihu")?.string(forKey: Constants.customClientId.rawValue)
    }
    
    static func getCustomClientSecret() -> String? {
        UserDefaults(suiteName: "group.nunesdennis.chihu")?.string(forKey: Constants.customClientSecret.rawValue)
    }
}
