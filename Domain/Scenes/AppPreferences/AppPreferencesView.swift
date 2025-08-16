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
    
    @State var hideNeoDBscore: Bool
    @State var hideYourScore: Bool
    
    let neoDBScoreModel = PreferenceCell(title: "NeoDB 🧩", description: "Hide NeoDB scores from under cards and review screen.")
    let yourScoreModel = PreferenceCell(title: "Your Scores", description: "Hide your scores from under cards.")
    
    init() {
        hideYourScore = !UserSettings.shared.showYourScore
        hideNeoDBscore = !UserSettings.shared.showNeoDBscore
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Hide preferences")) {
                    textCell(preferenceCell: neoDBScoreModel, isOn: $hideNeoDBscore)
                    textCell(preferenceCell: yourScoreModel, isOn: $hideYourScore)
                }
                .listRowBackground(Color.thanksToViewRowBackgroundColor)
            }
            .toolbarBackground(Color.thanksToViewBackgroundColor, for: .navigationBar)
            .background(Color.thanksToViewBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("App Preferences")
            .onChange(of: hideYourScore) {
                UserSettings.shared.showYourScore = !hideYourScore
            }
            .onChange(of: hideNeoDBscore) {
                UserSettings.shared.showNeoDBscore = !hideNeoDBscore
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
