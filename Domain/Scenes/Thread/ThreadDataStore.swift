//
//  ThreadDataStore.swift
//  Chihu
//
//

import Foundation
import TootSDK
import SwiftUI

enum ThreadAlertType {
    case success
    case error
    case delete
    case actionFailed
    case deleteError
}

enum ThreadState {
    case firstLoad
    case textLoaded
    case loaded
    case empty
    case canLoad
    case noMoreLoading
    case error
}

final class ThreadDataStore {
    var referencePost: Post
    var alertType: TimelineAlertType?
    var alertMessage: LocalizedStringKey?
    var lastError: Error?
    
    init(referencePost: Post) {
        self.referencePost = referencePost
    }
}
