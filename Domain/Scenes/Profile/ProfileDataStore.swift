//
//  ProfileDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
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
