//
//  AppPreferencesView.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 20/07/25.
//

import SwiftUI

struct PreferenceCell: Identifiable {
    var id = UUID()
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    init(title: LocalizedStringKey, description: LocalizedStringKey) {
        self.title = title
        self.description = description
    }
}

struct AppPreferencesView: View {
    
    @State var showNeoDBscore: Bool
    @State var showYourScore: Bool
    
    let neoDBScoreModel = PreferenceCell(title: "NeoDB 🧩", description: "Hide NeoDB scores from under cards and review screen.")
    let yourScoreModel = PreferenceCell(title: "Your Scores", description: "Hide your scores from under cards.")
    
    init() {
        showYourScore = UserSettings.shared.showYourScore
        showNeoDBscore = UserSettings.shared.showNeoDBscore
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Hide preferences")) {
                    textCell(preferenceCell: neoDBScoreModel, isOn: $showNeoDBscore)
                    textCell(preferenceCell: yourScoreModel, isOn: $showYourScore)
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
            }
            .toolbarBackground(Color.thanksToViewBackgroundColor, for: .navigationBar)
            .background(Color.thanksToViewBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("App Preferences")
            .onChange(of: showYourScore) {
                UserSettings.shared.showYourScore = showYourScore
            }
            .onChange(of: showNeoDBscore) {
                UserSettings.shared.showNeoDBscore = showNeoDBscore
            }
        }
    }
    
    func textCell(preferenceCell: PreferenceCell, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(preferenceCell.title)
                .multilineTextAlignment(.leading)
            Toggle(isOn: isOn) {
                Text(preferenceCell.description)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.chihuGray)
            }
            .toggleStyle(SwitchToggleStyle(tint: .chihuGreen))
        }
    }
}

#Preview {
    AppPreferencesView()
}
