//
//  Visibility.swift
//  Chihu
//
//

import SwiftUI
import TootSDK

enum Visibility: Int {
    case `public`
    case followersOnly
    case mentionedOnly
    
    func visibilityButtonName() -> LocalizedStringKey {
        switch self {
        case .public: return "Public"
        case .followersOnly: return "Followers Only"
        case .mentionedOnly: return "Mentioned Only"
        }
    }
    
    func TootSDKVisibility() -> Post.Visibility {
        switch self {
        case .public: return .public
        case .followersOnly: return .private
        case .mentionedOnly: return .direct
        }
    }
}
