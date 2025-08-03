//
//  RootSettingView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/09/24.
//

import SwiftUI

struct RootSettingView: View {
    let viewToDisplay: SettingsOptions
    
    var body: some View {
        switch viewToDisplay {
        case .supportDev:
            SupportTheDevView()
        case .aboutTheApp:
            AboutView()
        case .gratitude:
            ThanksToView()
        case .themes:
            ThemesView()
        case .appPreferences:
            AppPreferencesView()
        default:
            Text(viewToDisplay.rawValue)
        }
    }
}
