//
//  SettingsDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import Foundation
import SwiftUI
import PhotosUI

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
}
