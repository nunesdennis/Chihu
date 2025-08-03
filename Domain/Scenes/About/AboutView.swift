//
//  AboutView.swift
//  Chihu
//
//  Created by Dennis Nunes on 19/10/24.
//

import SwiftUI

struct AboutView: View {
    
    // Localized Strings
    static let appNamePlaceHolderLocalized = NSLocalizedString("This app", comment: "")
    static let fullTextLocalized = NSLocalizedString("about.text", comment: "")
    // Strings
    static let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    static let appNamePlaceHolder = String(format: appNamePlaceHolderLocalized)
    
    let fullText = String(format: fullTextLocalized, appName ?? appNamePlaceHolder)
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(fullText)
                }
                .listRowBackground(Color.settingsRowBackgroundColor)
            }
            .toolbarBackground(Color.settingsBackgroundColor, for: .navigationBar)
            .background(Color.settingsBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("About")
        }
    }
}

#Preview {
    AboutView()
}
