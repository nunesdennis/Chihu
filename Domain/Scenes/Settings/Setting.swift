//
//  Setting.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/09/24.
//

import SwiftUI

enum SettingsOptions: LocalizedStringKey {
    case supportDev = "Support the developer"
    case gratitude = "Thanks to"
    case aboutTheApp = "About the app"
    case contactTheDev = "Contact the dev"
    case themes = "Themes"
    case appPreferences = "App Preferences"
    
    func url() -> URL? {
        if self == .contactTheDev {
            return URL(string: "https://social.nunesdennis.me")
        }
        
        return nil
    }
}

struct Setting: Hashable {
    let option: SettingsOptions
    let color: Color
    let imageName: String
}
