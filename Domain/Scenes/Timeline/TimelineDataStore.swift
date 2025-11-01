//
//  TimelineDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//

import Foundation
import TootSDK
import SwiftUI

enum TimelineState {
    case firstLoad
    case textLoaded
    case loaded
    case empty
    case canLoad
    case noMoreLoading
    case error
}

enum TimelineAlertType {
    case success
    case error
    case delete
    case actionFailed
    case deleteError
}

final class TimelineDataStore: ObservableObject {
    @Published var state: TimelineState = .firstLoad
    @Published var shouldShowAlert = false
    @Published var showReplyView: Bool = false
    @Published var shouldShowToast: Bool = false
    @Published var posts: [Post] = []
    var alertType: TimelineAlertType?
    var postClicked: Post?
    var replyPostClicked: Post?
    var imagesDictionary: [String : ImageState] = [:]
    var imagesDictionaryURL: [URL : ImageState] = [:]
    var avatarImagesDictionary: [String : ImageState] = [:]
    var alertMessage: LocalizedStringKey?
    var lastError: Error?
}
