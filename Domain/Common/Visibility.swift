//
//  Visibility.swift
//  Chihu
//
//  Created by Dennis Nunes on 28/11/24.
//

import SwiftUI

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
}
