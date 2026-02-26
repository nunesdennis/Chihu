//
//  Button+Extension.swift
//  Chihu
//
//

import SwiftUI

extension Button {
    @ViewBuilder
    func chihuButtonStyle() -> some View {
        self.buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))
    }
}
