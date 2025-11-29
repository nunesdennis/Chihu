//
//  UserDetailsDataStore.swift
//  Chihu
//

import Foundation
import TootSDK
import SwiftUI

enum UserDetailsAlertType {
    case success
    case error
    case delete
    case actionFailed
    case deleteError
}

enum UserDetailsState {
    case firstLoad
    case textLoaded
    case loaded
    case empty
    case canLoad
    case noMoreLoading
    case error
}

final class UserDetailsDataStore {
    var user: Account
    var alertType: TimelineAlertType?
    var alertMessage: LocalizedStringKey?
    var lastError: Error?
    
    init(user: Account) {
        self.user = user
    }
}
