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

final class TimelineDataStore: ObservableObject {
    @Published var state: TimelineState = .firstLoad
    @Published var shouldShowAlert = false
    var imagesDictionary: [String : ImageState] = [:]
    var imagesDictionaryURL: [URL : ImageState] = [:]
    var avatarImagesDictionary: [String : ImageState] = [:]
    var alertMessage: LocalizedStringKey?
    var lastError: Error?
    var posts: [Post] = []
}
