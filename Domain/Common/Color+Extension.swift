//
//  Color+Extension.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//

import Foundation
import SwiftUI

enum Theme: String {
    case lightModeDefault
    case darkModeDefault
    
    func buttonName() -> String {
        switch self {
        case .lightModeDefault, .darkModeDefault:
            return "Default"
        }
    }
}

// Base colors
extension Color {
    public static var cornSilk: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 254/255, green: 250/255, blue: 224/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0))
        }
    }
    
    public static var halfDutchWhite: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 250/255, green: 237/255, blue: 206/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0))
        }
    }
    
    public static var tusk: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 224/255, green: 229/255, blue: 182/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1.0))
        }
    }
    
    public static var orinoco: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 204/255, green: 213/255, blue: 174/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 72/255, green: 72/255, blue: 74/255, alpha: 1.0))
        }
    }
    
    public static var springRain: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 164/255, green: 185/255, blue: 160/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 99/255, green: 99/255, blue: 102/255, alpha: 1.0))
        }
    }
    
    public static var givry: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 233/255, green: 205/255, blue: 174/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 112/255, green: 112/255, blue: 114/255, alpha: 1.0))
        }
    }
    
    public static var parisWhite: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            Color(UIColor(red: 191/255, green: 206/255, blue: 188/255, alpha: 1.0))
        case .darkModeDefault:
            Color(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0))
        }
    }
    
    public static var chihuGreen: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            .green
        case .darkModeDefault:
            Color(UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 1.0))
        }
    }
    
    public static var chihuRed: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            .red
        case .darkModeDefault:
            Color(UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1.0))
        }
    }
    
    public static var chihuClear: Color {
        .clear
    }
    
    public static var chihuBlue: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            .blue
        case .darkModeDefault:
            Color(UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1.0))
        }
    }
    
    public static var chihuYellow: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            .yellow
        case .darkModeDefault:
            Color(UIColor(red: 255/255, green: 214/255, blue: 10/255, alpha: 1.0))
        }
    }
    
    public static var chihuGray: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            .gray
        case .darkModeDefault:
            Color(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0))
        }
    }
    
    public static var chihuBlack: Color {
        switch UserSettings.shared.selectedTheme {
        case .lightModeDefault:
            return Color(red: 30/255, green: 27/255, blue: 27/255)
        case .darkModeDefault:
            return .white
        }
    }
}

// Colors used
extension Color {
    // Header Profile
    public static var headerProfileColor: Color {
        .tusk
    }
    
    // Profile
    public static var profileDisplayNameColor: Color {
        .primary
    }
    
    public static var profileUsernameColor: Color {
        .secondary
    }
    
    public static var profilePostGridColor: Color {
        .chihuClear
    }
    
    public static var profileViewColor: Color {
        .cornSilk
    }
    
    public static var expandShelfTypeButton: Color {
        .chihuGreen
    }
    
    // Card grid
    public static var cardViewColor: Color {
        .primary
    }
    
    public static var shelfListGridColor: Color {
        .chihuClear
    }
    
    // Search
    public static var searchViewColor: Color {
        .cornSilk
    }
    
    public static var searchBarSearchViewButtonColor: Color {
        .chihuGreen
    }
    
    // Filter
    public static var filterButtonSelectedColor: Color {
        .chihuGreen
    }
    
    public static var filterButtonNotSelectedColor: Color {
        .parisWhite
    }
    
    // Tabbar
    public static var tabbarButtonColor: Color {
        .chihuGreen
    }
    
    public static var tabbarBackgroundColor: Color {
        .cornSilk
    }
    
    // Review
    public static var externalResourcesReviewViewRowBackgroundColor: Color {
        .cornSilk
    }
    
    public static var reviewBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var reviewCommentBackgroundColor: Color {
        .cornSilk
    }
    
    public static var reviewActionButtonColor: Color {
        .chihuGreen
    }
    
    public static var reviewDeleteButtonColor: Color {
        .chihuRed
    }
    
    public static var reviewFilterButtonSelectedColor: Color {
        .chihuGreen
    }
    
    public static var postListBackgroundColor: Color {
        .cornSilk
    }
    
    // Login
    public static var loginNewServerUrlBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var loginInstanceTextFieldBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var loginBackgroundColor: Color {
        .cornSilk
    }
    
    public static var loginPrimaryBackgroundColor: Color {
        .springRain
    }
    
    public static var loginSecondaryBackgroundColor: Color {
        .parisWhite
    }
    
    public static var headerLoginColor: Color {
        .tusk
    }
    
    public static var loginRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    // Settings
    public static var settingsBackgroundColor: Color {
        .cornSilk
    }
    
    public static var settingsRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    // Support the dev
    public static var supportTheDevBackgroundColor: Color {
        .cornSilk
    }
    
    public static var supportTheDevRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    // Scanner
    public static var scannerViewColor: Color {
        .cornSilk
    }
    
    // Timeline
    public static var timelineNavBackgroundColor: Color {
        .cornSilk
    }
    
    public static var timelineBackgroundColor: Color {
        .cornSilk
    }
    
    public static var timelineCellBackgroundColor: Color {
        .chihuClear
    }
    
    public static var timelineCellRepostIconColor: Color {
        .chihuGreen
    }
    
    // Error view
    public static var errorViewBackgroundColor: Color {
        .cornSilk
    }
    
    // Thanks to
    public static var thanksToViewRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var thanksToViewBackgroundColor: Color {
        .cornSilk
    }
    
    // Markdown Editor
    public static var markdownEditorBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var markdownEditorEditorBackgroundColor: Color {
        .cornSilk
    }
    
    // Share sheet
    public static var shareSheetBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var shareSheetLoadingColor: Color {
        .chihuGreen
    }
    
    // Simple Collection List View
    public static var simpleCollectionListViewRowBackgroundColor: Color {
        .cornSilk
    }
    
    public static var simpleCollectionListViewSelectedRowBackgroundColor: Color {
        .tusk
    }
    
    // Collection View
    public static var collectionViewBackgroundColor: Color {
        .cornSilk
    }
    
    public static var collectionViewRowBackgroundColor: Color {
        .cornSilk
    }
    
    public static var collectionViewSectionBackgroundColor: Color {
        .halfDutchWhite
    }
    
    // New Collection View
    public static var newCollectionCommentBackgroundColor: Color {
        .cornSilk
    }
    
    public static var newCollectionViewBackgroundColor: Color {
        .halfDutchWhite
    }
    
    // Simple Note List View
    public static var simpleNoteListViewRowBackgroundColor: Color {
        .cornSilk
    }
    
    // Themes
    public static var themesViewRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var themesViewSelectedRowBackgroundColor: Color {
        .tusk
    }
    
    public static var themesViewBackgroundColor: Color {
        .cornSilk
    }
    
    // App Preferences
    public static var appPreferencesViewRowBackgroundColor: Color {
        .halfDutchWhite
    }
    
    public static var appPreferencesViewBackgroundColor: Color {
        .cornSilk
    }
}
