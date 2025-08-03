//
//  View+ColorSchema.swift
//  Chihu
//
//  Created by Dennis Nunes on 03/04/25.
//

import SwiftUI

extension View {
    func colorScheme() -> some View {
        let selectedTheme = UserSettings.getTheme()
        
        switch selectedTheme {
        case .lightModeDefault:
            return self.preferredColorScheme(.light)
        case .darkModeDefault:
            return self.preferredColorScheme(.dark)
        }
    }
}
