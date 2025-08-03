//
//  SpoilerModifier.swift
//  Chihu
//
//  Created by Dennis Nunes on 19/03/25.
//

import SwiftUI

struct SpoilerModifier: ViewModifier {

    let isOn: Bool

    func body(content: Content) -> some View {
        content.overlay {
            SpoilerView(isOn: isOn)
        }
    }
}
