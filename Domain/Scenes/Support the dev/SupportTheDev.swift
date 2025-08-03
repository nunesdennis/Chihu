//
//  SupportTheDev.swift
//  Chihu
//
//  Created by Dennis Nunes on 19/10/24.
//

import SwiftUI
import StoreKit

struct Tip: Hashable {
    let id: String
    let title: String
}

struct SupportTheDevView: View {
    
    var ids: [String] = [
        "me.nunesdennis.Chihu.tip.kind",
        "me.nunesdennis.Chihu.tip.generous",
        "me.nunesdennis.Chihu.tip.bountiful",
        "me.nunesdennis.Chihu.tip.supporter"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ids, id: \.self) { id in
                    ProductView(id: id)
                        .productViewStyle(.compact)
                }
                .listRowBackground(Color.supportTheDevRowBackgroundColor)
            }
            .navigationTitle("Tip Jar")
            .background(Color.supportTheDevBackgroundColor)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    SupportTheDevView()
}
