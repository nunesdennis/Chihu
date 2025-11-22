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
    
    public static var timelineButtonCellHighlightedColor: Color {
        .chihuGreen
    }
    
    public static var timelineButtonCellNormalColor: Color {
        .parisWhite
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
    
    // Reply
    public static var replyViewBackgroundColor: Color {
        .halfDutchWhite
    }
}
