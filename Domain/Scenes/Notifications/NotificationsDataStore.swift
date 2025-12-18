//
//  NotificationsDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//

import Foundation
import TootSDK
import SwiftUI

enum NotificationsState {
    case firstLoad
    case textLoaded
    case loaded
    case empty
    case canLoad
    case noMoreLoading
    case error
}

enum NotificationsAlertType {
    case success
    case error
    case delete
    case actionFailed
    case deleteError
}

final class NotificationsDataStore: ObservableObject {
    @Published var state: TimelineState = .firstLoad
    @Published var shouldShowAlert = false
    @Published var showReplyView: Bool = false
    @Published var shouldShowToast: Bool = false
    @Published var notifications: [TootNotification] = []
    @Published var openThread: Bool = false
    @Published var openUserDetails: Bool = false
    var alertType: TimelineAlertType?
    var accountClicked: Account?
    var postClicked: Post?
    var replyPostClicked: Post?
    var alertMessage: LocalizedStringKey?
    var lastError: Error?
    
    var threadDataStore: ThreadDataStore?
    var userDetailsDataStore: UserDetailsDataStore?
    
    func createNewThreadDataStore(with post: Post) -> ThreadDataStore {
        guard let threadDataStore else {
            let dataStore = ThreadDataStore(referencePost: post)
            self.threadDataStore = dataStore
            return dataStore
        }
        
        if post.id == threadDataStore.referencePost.id {
            return threadDataStore
        }
        
        let dataStore = ThreadDataStore(referencePost: post)
        self.threadDataStore = dataStore
        return dataStore
    }
    
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
