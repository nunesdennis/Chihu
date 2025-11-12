//
//  View+ColorSchema.swift
//  Chihu
//
//  Created by Dennis Nunes on 03/04/25.
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
