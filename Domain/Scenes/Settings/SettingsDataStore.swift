//
//  SettingsDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import Foundation

enum SettingsState {
    case loading
    case loaded
    case error
}

final class SettingsDataStore: ObservableObject {
    @Published var state: SettingsState = .loading
    @Published var profileViewModel: Profile.Load.ViewModel?
}
