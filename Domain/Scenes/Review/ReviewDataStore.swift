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
    var visibility: Visibility = .public
    var alertType: ReviewAlertType?
    var alertMessage: LocalizedStringKey?
    var collectionSelected: CollectionModel?
    var noteSelected: NoteSchema?
    var seasonSelected: ItemViewModel?
    var posts: [CatalogPostsModel.Load.ViewModel.Post] = []
    var noteList: [NoteSchema] = []
    var noteListNeedsToUpdate: Bool = true
    
    @Published var shelfType: ShelfType = .complete
    @Published var item: ItemViewModel!
    @Published var shouldShowAlert = false
    @Published var shouldShowToast = false
    @Published var state: ReviewState = .full
    @Published var rating: Double? = nil
    @Published var inputText: String = String()
    @Published var titleInputText: String = String()
    @Published var bodyInputText: String = String()
    @Published var collectionList: [CollectionModel] = []
    @Published var collectionNoteInputText: String = String()
    @Published var progressNoteInputText: String = String()
    @Published var progressNoteValueInputText: String = String()
    @Published var progressNoteContentWarningInputText: String = String()
    @Published var shouldPushToSeason: Bool = false
    @Published var selectedVisibility: Int!
    @Published var selectedShelfType: Int = 0
    @Published var shouldCrosspost: Bool!
    
    private var reviewDataStore: ReviewDataStore?
    
    func createNewReviewDataStore() -> ReviewDataStore {
        if seasonSelected?.id == reviewDataStore?.item?.id, let reviewDataStore {
            return reviewDataStore
        }
        
        self.reviewDataStore = ReviewDataStore()
        
        return reviewDataStore ?? ReviewDataStore()
    }
}
