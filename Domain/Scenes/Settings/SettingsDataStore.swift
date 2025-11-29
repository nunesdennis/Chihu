//
//  SettingsDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import Foundation
import SwiftUI
import PhotosUI
import TootSDK

enum SettingsState {
    case loading
    case loaded
    case error
}

final class SettingsDataStore: ObservableObject {
    @Published var state: SettingsState = .loading
    @Published var profileViewModel: Profile.Load.ViewModel?
    
    // Photo picker state properties
    @Published var isPhotoPickerPresented = false
    @Published var isUpdatingAvatar = false
    @Published var mediaPickers: [PhotosPickerItem] = []
    @Published var showAlert = false
    @Published var showError = false
    @Published var errorMessage: LocalizedStringKey = ""
    @Published var alertMessage: LocalizedStringKey = ""
    @Published var openUserDetails: Bool = false
    
    var userDetailsDataStore: UserDetailsDataStore?
    var accountClicked: Account?
    
    func createNewUserDetailsDataStore(with account: Account) -> UserDetailsDataStore {
        guard let userDetailsDataStore else {
            let dataStore = UserDetailsDataStore(user: account)
            self.userDetailsDataStore = dataStore
            return dataStore
        }
        
        if account.id == userDetailsDataStore.user.id {
            return userDetailsDataStore
        }
        
        let dataStore = UserDetailsDataStore(user: account)
        self.userDetailsDataStore = dataStore
        return dataStore
    }
}
