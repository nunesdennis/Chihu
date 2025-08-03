//
//  EmptyView.swift
//  Chihu
//
//  Created by Dennis Nunes on 17/11/24.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("emptyView")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.chihuGray)
                .frame(width: 60, height: 60)
                .opacity(0.1)
                .offset(x: 0, y: -100)
            Spacer()
        }
        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
    }
}

#Preview {
    EmptyView()
}
