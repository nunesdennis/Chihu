//
//  Button+Extension.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 20/09/25.
//

import SwiftUI

extension Button {
    @ViewBuilder
    func chihuButtonStyle() -> some View {
        self.buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))
    }
}
