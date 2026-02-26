//
//  View+ColorSchema.swift
//  Chihu
//
//

import SwiftUI

extension View {
    func colorScheme() -> some View {
        self.preferredColorScheme(getColorScheme())
    }
    
    func getColorScheme() -> ColorScheme? {
        if UserSettings.shared.shouldUseSystemTheme {
            return nil
        }
        
        if UserSettings.shared.selectedTheme == .lightModeDefault {
            return .light
        } else {
            return .dark
        }
    }
}
