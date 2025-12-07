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
    @Published var segmentedControlSelection: Int = 0
    @Published var followingPosts: [Post] = []
    @Published var localPosts: [Post] = []
    @Published var globalPosts: [Post] = []
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
    
    var posts: [Post] {
        get {
            switch segmentedControlSelection {
            case 0:
                return followingPosts
            case 1:
                return localPosts
            case 2:
                return globalPosts
            default:
                return followingPosts
            }
        }
        set {
            switch segmentedControlSelection {
            case 0:
                followingPosts = newValue
            case 1:
                localPosts = newValue
            case 2:
                globalPosts = newValue
            default:
                followingPosts = newValue
            }
        }
    }
    
    func appendToCurrentPosts(_ posts: [Post]) {
        switch segmentedControlSelection {
        case 0:
            followingPosts.append(contentsOf: posts)
        case 1:
            localPosts.append(contentsOf: posts)
        case 2:
            globalPosts.append(contentsOf: posts)
        default:
            followingPosts.append(contentsOf: posts)
        }
    }
    
    @discardableResult
    func updatePost(_ post: Post) -> Bool {
        let updateArray = { (array: inout [Post]) -> Bool in
            if let index = array.firstIndex(where: { $0.id == post.id }) {
                array[index] = post
                return true
            }
            return false
        }
        
        return updateArray(&followingPosts) || updateArray(&localPosts) || updateArray(&globalPosts)
    }
    
    func removePost(_ post: Post) {
        switch segmentedControlSelection {
        case 0:
            followingPosts.removeAll {
                $0.id == post.id
            }
        case 1:
            localPosts.removeAll {
                $0.id == post.id
            }
        case 2:
            globalPosts.removeAll {
                $0.id == post.id
            }
        default:
            followingPosts.removeAll {
                $0.id == post.id
            }
        }
    }
    
    func insertPostAtBeginning(_ post: Post) {
        switch segmentedControlSelection {
        case 0:
            followingPosts.insert(post, at: 0)
        case 1:
            localPosts.insert(post, at: 0)
        case 2:
            globalPosts.insert(post, at: 0)
        default:
            followingPosts.insert(post, at: 0)
        }
    }
    
    func findPostIndex(_ postId: String) -> Int? {
        return posts.firstIndex { $0.id == postId }
    }
    
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
