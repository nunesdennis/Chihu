//
//  SpoilerModifier.swift
//  Chihu
//
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
