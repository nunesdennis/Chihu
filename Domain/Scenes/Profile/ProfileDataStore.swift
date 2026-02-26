//
//  ProfileDataStore.swift
//  Chihu
//
//  
//

import Foundation

enum ProfileState {
    case loading
    case loaded
    case error
}

final class ProfileDataStore: ObservableObject {
    @Published var state: ProfileState = .loading
    @Published var viewModel: Profile.Load.ViewModel?
    @Published var showShelfTypeExpanded: Bool = false
    var lastError: Error?
}
