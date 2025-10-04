//
//  ReviewDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//  
//

import Foundation
import SwiftUI

enum ReviewState {
    case loading
    case full
    case markdownEditor
    case description
    case poster
}

enum ReviewAlertType {
    case success
    case error
    case delete
    case actionFailed
    case deleteError
}

final class ReviewDataStore: ObservableObject {
    var visibility: Visibility
    var alertType: ReviewAlertType?
    var alertMessage: LocalizedStringKey?
    var collectionSelected: CollectionModel?
    var noteSelected: NoteSchema?
    var seasonSelected: ItemViewModel?
    var posts: [CatalogPostsModel.Load.ViewModel.Post]
    var noteList: [NoteSchema]
    var postClicked: PostProtocol?
    var noteListNeedsToUpdate: Bool
    
    @Published var showReplyView: Bool = false
    @Published var showUpdateReplyView: Bool = false
    @Published var shelfType: ShelfType
    @Published var item: ItemViewModel!
    @Published var shouldShowAlert: Bool
    @Published var shouldShowToast: Bool
    @Published var showFullReviewMarkdownPreview: Bool
    @Published var state: ReviewState
    @Published var rating: Double?
    @Published var inputText: String
    @Published var titleInputText: String
    @Published var bodyInputText: String
    @Published var collectionList: [CollectionModel]
    @Published var collectionNoteInputText: String
    @Published var progressNoteInputText: String
    @Published var progressNoteValueInputText: String
    @Published var progressNoteContentWarningInputText: String
    @Published var shouldPushToSeason: Bool
    @Published var selectedVisibility: Int!
    @Published var selectedShelfType: Int
    @Published var shouldCrosspost: Bool!
    
    private var reviewDataStore: ReviewDataStore?
    
    init(
        alertType: ReviewAlertType? = nil,
        alertMessage: LocalizedStringKey? = nil,
        collectionSelected: CollectionModel? = nil,
        noteSelected: NoteSchema? = nil,
        seasonSelected: ItemViewModel? = nil,
        posts: [CatalogPostsModel.Load.ViewModel.Post] = [],
        noteList: [NoteSchema] = [],
        noteListNeedsToUpdate: Bool = true,
        shouldShowAlert: Bool = false,
        shouldShowToast: Bool = false,
        state: ReviewState = .full,
        rating: Double? = nil,
        inputText: String = "",
        titleInputText: String = "",
        bodyInputText: String = "",
        collectionList: [CollectionModel] = [],
        collectionNoteInputText: String = "",
        progressNoteInputText: String = "",
        progressNoteValueInputText: String = "",
        progressNoteContentWarningInputText: String = "",
        shouldPushToSeason: Bool = false,
        reviewDataStore: ReviewDataStore? = nil
    ) {
        let defaultVisibility = UserSettings.shared.userPreference?.defaultVisibility ?? .public
        self.selectedVisibility = defaultVisibility.rawValue
        self.visibility = defaultVisibility
        
        let defaultShelfType = ShelfType(rawValue: UserSettings.shared.defaultShelfType) ?? .complete
        self.selectedShelfType = defaultShelfType.rawValueInt()
        self.shelfType = defaultShelfType
        
        self.shouldCrosspost = UserSettings.shared.userPreference?.defaultCrosspost
        self.alertType = alertType
        self.alertMessage = alertMessage
        self.collectionSelected = collectionSelected
        self.noteSelected = noteSelected
        self.seasonSelected = seasonSelected
        self.posts = posts
        self.noteList = noteList
        self.noteListNeedsToUpdate = noteListNeedsToUpdate
        self.shouldShowAlert = shouldShowAlert
        self.shouldShowToast = shouldShowToast
        self.state = state
        self.rating = rating
        self.inputText = inputText
        self.titleInputText = titleInputText
        self.bodyInputText = bodyInputText
        self.collectionList = collectionList
        self.collectionNoteInputText = collectionNoteInputText
        self.progressNoteInputText = progressNoteInputText
        self.progressNoteValueInputText = progressNoteValueInputText
        self.progressNoteContentWarningInputText = progressNoteContentWarningInputText
        self.shouldPushToSeason = shouldPushToSeason
        self.reviewDataStore = reviewDataStore
        showFullReviewMarkdownPreview = false
    }
    
    func createNewReviewDataStore() -> ReviewDataStore {
        if seasonSelected?.id == reviewDataStore?.item?.id, let reviewDataStore {
            return reviewDataStore
        }
        
        self.reviewDataStore = ReviewDataStore()
        
        return reviewDataStore ?? ReviewDataStore()
    }
}
