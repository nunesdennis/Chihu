//
//  ThemesView.swift
//  Chihu
//
//  Created by Dennis Nunes on 03/04/25.
//


import SwiftUI

struct ThemeItem: Identifiable {
    let id = UUID()
    let name: Theme
}

struct ThemesView: View {
    
    @State private var selection: String?
    
    var themeList: [ThemeItem] = [
        ThemeItem(name: .lightModeDefault)
    ]
    
    var darkThemeList: [ThemeItem] = [
        ThemeItem(name: .darkModeDefault)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Light Mode")) {
                    ForEach(themeList) { theme in
                        Button(action: {
                            UserSettings.shared.saveTheme(theme.name)
                            selection = theme.name.rawValue
                        }) {
                            HStack {
                                Text(theme.name.buttonName())
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(4)
                            // This color is redundant, but it increases the button area
                            .background(getColor(from: theme.name.rawValue))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(getColor(from: theme.name.rawValue))
                    }
                }
                Section(header: Text("Dark Mode")) {
                    ForEach(darkThemeList) { theme in
                        Button(action: {
                            UserSettings.shared.saveTheme(theme.name)
                            selection = theme.name.rawValue
                        }) {
                            HStack {
                                Text(theme.name.buttonName())
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(4)
                            // This color is redundant, but it increases the button area
                            .background(getColor(from: theme.name.rawValue))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(getColor(from: theme.name.rawValue))
                    }
                }
            }
            .task {
                selection = UserSettings.shared.selectedTheme.rawValue
            }
            .background(Color.themesViewBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("Themes")
            .colorScheme()
        }
    }
    
    func getColor(from selection: String) -> Color {
        return self.selection == selection
                               ? Color.themesViewSelectedRowBackgroundColor
                               : Color.themesViewRowBackgroundColor
    }
}

#Preview {
    ThemesView()
}
