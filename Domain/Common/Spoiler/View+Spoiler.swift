//
//  View+Spoiler.swift
//  Chihu
//
//  Created by Dennis Nunes on 19/03/25.
//

import SwiftUI

extension View {
    func spoiler(isOn: Binding<Bool>) -> some View {
        self
            .if(isOn.wrappedValue, transform: { view in
                view
                    .opacity(isOn.wrappedValue ? 0 : 1)
                    .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
                    .onTapGesture {
                        withAnimation() {
                            isOn.wrappedValue = false
                        }
                    }
            })
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
