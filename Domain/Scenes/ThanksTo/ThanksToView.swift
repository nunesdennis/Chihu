//
//  ThanksToView.swift
//  Chihu
//
//  Created by Dennis Nunes on 29/11/24.
//

import SwiftUI

struct CellInfo: Identifiable {
    var id = UUID()
    let title: String
    let description: LocalizedStringKey?
    let url: String?
    
    init(title: String, description: LocalizedStringKey? = nil, url: String? = nil) {
        self.title = title
        self.description = description
        self.url = url
    }
}

struct ThanksToView: View {
    
    @Environment(\.openURL) var openURL
    
    @State var shouldShowAlert = false
    
    var friends: [CellInfo] = [
        .init(title: "Danilo Kleber", description: "Backend Consultant"),
        .init(title: "All the testers"),
        .init(title: "NeoDB Team", url: "https://neodb.net")
    ]
    
    var blogs: [CellInfo] = [
        .init(title: "Hacking with Swift", url: "https://www.hackingwithswift.com"),
        .init(title: "Artem Novichkov", url: "https://www.artemnovichkov.com/blog/spoiler-view")
    ]
    
    var youtube: [CellInfo] = [
        .init(title: "Rebel Developer", url: "https://www.youtube.com/@rebeloper"),
        .init(title: "AzamSharp", url: "https://www.youtube.com/@azamsharp")
    ]
    
    var gits: [CellInfo] = [
        .init(title: "TootSDK", description: "BSD-3-Clause license", url: "https://github.com/TootSDK/TootSDK"),
        .init(title: "MarkdownUI", description: "MIT License", url: "https://github.com/gonzalezreal/swift-markdown-ui"),
        .init(title: "VIP Clean Architecture Pattern with SwiftUI", description: "MIT License", url: "https://github.com/arthurgivigir/vip-swiftui-template-xcode"),
        .init(title: "HTML2Markdown", description: "MIT License", url: "https://gitlab.com/mflint/HTML2Markdown"),
        .init(title: "Ice Cubes App", description: "AGPL-3.0 License", url: "https://github.com/Dimillian/IceCubesApp"),
        .init(title: "Fedicat App", description: "MIT License", url: "https://codeberg.org/technicat/fedicat")
    ]
    
    var localization: [CellInfo] = [
        .init(title: "Emanuele Cariati", description: "Italian")
    ]
    
    func textCell(cellInfo: CellInfo) -> some View {
        VStack(alignment: .leading) {
            Text(cellInfo.title)
                .multilineTextAlignment(.leading)
            if let description = cellInfo.description {
                Text(description)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.chihuGray)
            }
        }
    }
    
    func linkCell(cellInfo: CellInfo) -> some View {
        Button {
            if let urlString = cellInfo.url,
               let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            VStack(alignment: .leading)  {
                Text(cellInfo.title)
                    .multilineTextAlignment(.leading)
                if let description = cellInfo.description {
                    Text(description)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.chihuGray)
                }
            }
        }
        .tint(Color.chihuBlack)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("People")) {
                    ForEach(friends) { friend in
                        if let _ = URL(string: friend.url ?? String()) {
                            linkCell(cellInfo: friend)
                        } else {
                            textCell(cellInfo: friend)
                        }
                    }
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
                Section(header: Text("Blogs")) {
                    ForEach(blogs) { blog in
                        linkCell(cellInfo: blog)
                    }
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
                Section(header: Text("Youtube")) {
                    ForEach(youtube) { channel in
                        linkCell(cellInfo: channel)
                    }
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
                Section(header: Text("Projects")) {
                    ForEach(gits) { git in
                        linkCell(cellInfo: git)
                    }
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
                Section(header: Text("Localization")) {
                    ForEach(localization) { helper in
                        textCell(cellInfo: helper)
                    }
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
            }
            .toolbarBackground(Color.thanksToViewBackgroundColor, for: .navigationBar)
            .background(Color.thanksToViewBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("Thanks To")
            .alert("Alert", isPresented: $shouldShowAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("URL not working")
            }
        }
    }
}

#Preview {
    ThanksToView()
}
