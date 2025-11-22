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
    @State private var shouldUseSystemTheme: Bool = UserSettings.shared.shouldUseSystemTheme
    
    var themeList: [ThemeItem] = [
        ThemeItem(name: .lightModeDefault)
    ]
    
    var darkThemeList: [ThemeItem] = [
        ThemeItem(name: .darkModeDefault)
    ]
    
    var body: some View {
        NavigationStack {
            List {
//                Section(header: Text("System Mode")) {
//                    HStack {
//                        Text("Change from system theme")
//                            .font(.title3)
//                            .multilineTextAlignment(.leading)
//                        Spacer()
//                        Toggle(buttonSystemSettingsText(shouldUseSystemTheme), isOn: $shouldUseSystemTheme)
//                            .toggleStyle(.button)
//                            .buttonBorderShape(.roundedRectangle(radius: 8))
//                            .tint(buttonSystemSettingsColor(shouldUseSystemTheme))
//                            .onChange(of: shouldUseSystemTheme) {
//                                UserSettings.shared.saveShouldUseSystemTheme(shouldUseSystemTheme: shouldUseSystemTheme)
//                            }
//                    }
//                    .listRowBackground(Color.themesViewRowBackgroundColor)
//                }
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
            .preferredColorScheme(getColorScheme())
        }
    }
    
    func getColorScheme() -> ColorScheme? {
        if shouldUseSystemTheme {
            return nil
        }
        
        if selection == Theme.lightModeDefault.rawValue {
            return .light
        } else {
            return .dark
        }
    }
    
    func getColor(from selection: String) -> Color {
        return self.selection == selection
                               ? Color.themesViewSelectedRowBackgroundColor
                               : Color.themesViewRowBackgroundColor
    }
    
    func buttonSystemSettingsText(_ shouldUseSystemTheme: Bool) -> String {
        shouldUseSystemTheme ? "On" : "Off"
    }
    
    func buttonSystemSettingsColor(_ shouldUseSystemTheme: Bool) -> Color {
        shouldUseSystemTheme ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}

#Preview {
    ThemesView()
}
