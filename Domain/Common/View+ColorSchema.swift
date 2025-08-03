//
//  View+ColorSchema.swift
//  Chihu
//
//  Created by Dennis Nunes on 03/04/25.
//

import SwiftUI

extension View {
    func colorScheme() -> some View {
        self.preferredColorScheme(UserSettings.shared.colorScheme)
    }
}
