//
//  ReviewView.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//  
//

import SwiftUI
import Combine
import TootSDK

extension ReviewView: PostInteractionsDisplayLogic {
    func display(post: Post) {
        DispatchQueue.main.async {
            let index = dataStore.posts.firstIndex {
                $0.id == post.id
            }
            
            if let index {
                dataStore.posts[index] = post
            } else {
                dataStore.alertType = .actionFailed
                dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
                dataStore.shouldShowToast = true
            }
        }
    }
    
    func displayToastError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
        }
    }
}

extension ReviewView: ReviewDisplayLogic {
    func update(rateViewModel: Review.Update.ViewModel?,
                noteViewModel: ProgressNoteList.Update.ViewModel?) {
        DispatchQueue.main.async {
            if let item = rateViewModel?.shelfItemsViewModel {
                updateView(withItem: item)
            } else if let note = noteViewModel?.note{
                updateNote(withNote: note)
                resetNoteView()
            }
            dataStore.state = .full
        }
    }
    
    func displayActionError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
        }
    }
    
    func displayDeleteError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .deleteError
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
        }
    }
    
    func displayPosts(viewModel: CatalogPostsModel.Load.ViewModel) {
        dataStore.posts = viewModel.posts
        DispatchQueue.main.async {
            dataStore.state = .full
        }
    }
    
    func display(rateViewModel: Review.Delete.ViewModel?,
                 reviewViewModel: FullReview.Delete.ViewModel?,
                 collectionsItemViewModel: Collections.DeleteItems.ViewModel?) {
        DispatchQueue.main.async {
            dataStore.alertType = .success
            dataStore.alertMessage = LocalizedStringKey(rateViewModel?.message ?? reviewViewModel?.message ?? collectionsItemViewModel?.message ?? "Unknown Error")
            dataStore.shouldShowToast = true
        }
    }
    
    func displaySilentError(_ error: any Error) {
        print(error.localizedDescription)
    }
    
    func displayLoadingError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
            dataStore.state = .full
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
        }
    }
    
    func open(viewModel: Review.LoadSeason.ViewModel) {
        DispatchQueue.main.async {
            dataStore.seasonSelected = viewModel.shelfItemsViewModel
            dataStore.shouldPushToSeason = true
        }
    }
    
    func display(rateViewModel: Review.Load.ViewModel?, reviewViewModel: FullReview.Load.ViewModel?) {
        DispatchQueue.main.async {
            if let rateViewModel {
                updateView(withItem: rateViewModel.shelfItemsViewModel)
            } else if let reviewViewModel {
                updateView(withReview: reviewViewModel.shelfItemsViewModel)
            }
            dataStore.state = .full
        }
    }
    
    func display(rateViewModel: Review.Send.ViewModel?,
                 reviewViewModel: FullReview.Send.ViewModel?,
                 collectionsItemViewModel: Collections.SendItems.ViewModel?,
                 progressNoteListViewModel: ProgressNoteList.Send.ViewModel?) {
        DispatchQueue.main.async {
            if progressNoteListViewModel != nil {
                dataStore.noteListNeedsToUpdate = true
            }
            dataStore.alertType = .success
            dataStore.alertMessage = LocalizedStringKey(rateViewModel?.message ??
                                                        reviewViewModel?.message ??
                                                        collectionsItemViewModel?.message ?? "Sent")
            dataStore.shouldShowToast = true
        }
    }
    
    func sendRate() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        let shelfType = dataStore.shelfType.rawValue
        let visibility = dataStore.visibility.rawValue
        let shouldCrossPost = dataStore.shouldCrosspost ?? true
        let comment = dataStore.inputText
        let ratingFull = dataStore.rating != nil ? Int(dataStore.rating!*2) : nil
        let calculatedRating = dataStore.shelfType != .wishlist ? ratingFull : nil
        let requestBody = Review.Send.Request.ReviewRequestBody(shelfType: shelfType, visibility: visibility, comment: comment, rating: calculatedRating, tags: [], crosspost: shouldCrossPost)
        
        let requestReview = Review.Send.Request(body: requestBody, itemUUID: itemUUID)
        interactor.sendRate(request: requestReview)
    }
    
    func sendReview() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        let reviewTitle = dataStore.titleInputText
        let reviewBody = dataStore.bodyInputText
        let visibility = dataStore.visibility.rawValue
        let shouldCrossPost = dataStore.shouldCrosspost ?? true
        
        let requestBody = FullReview.Send.Request.ReviewRequestBody(visibility: visibility, title: reviewTitle, body: reviewBody, crosspost: shouldCrossPost)
        
        let requestReview = FullReview.Send.Request(body: requestBody, itemUUID: itemUUID)
        interactor.sendReview(request: requestReview)
    }
    
    func updateNote() {
        guard let noteUUID = dataStore.noteSelected?.uuid else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey("Note not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        let contentWarning = dataStore.progressNoteContentWarningInputText
        let content = dataStore.progressNoteInputText
        let sensitive = !contentWarning.isEmpty
        let hasProgress = progressTypeList[selectedProgressType] != .none
        let progressType: String = hasProgress ? progressTypeList[selectedProgressType].rawValue : String()
        let progressValue: String = hasProgress ? dataStore.progressNoteValueInputText : String()
        let visibility = dataStore.visibility.rawValue
        let shouldCrossPost = dataStore.shouldCrosspost ?? true
        
        let requestBody = ProgressNoteList.Update.Request.NoteRequestBody(
            title: contentWarning,
            content: content,
            sensitive: sensitive,
            progressType: progressType,
            progressValue: progressValue,
            visibility: visibility,
            postToFediverse: shouldCrossPost)
        let request = ProgressNoteList.Update.Request(body: requestBody, noteUuid: noteUUID)
        interactor.updateNote(request: request)
    }
    
    func addNewNote() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        let contentWarning = dataStore.progressNoteContentWarningInputText
        let content = dataStore.progressNoteInputText
        let sensitive = !contentWarning.isEmpty
        let hasProgress = progressTypeList[selectedProgressType] != .none
        let progressType: String = hasProgress ? progressTypeList[selectedProgressType].rawValue : String()
        let progressValue: String = hasProgress ? dataStore.progressNoteValueInputText : String()
        let visibility = dataStore.visibility.rawValue
        let shouldCrossPost = dataStore.shouldCrosspost ?? true
        
        let requestBody = ProgressNoteList.Send.Request.NoteRequestBody(
            title: contentWarning,
            content: content,
            sensitive: sensitive,
            progressType: progressType,
            progressValue: progressValue,
            visibility: visibility,
            postToFediverse: shouldCrossPost)
        let request = ProgressNoteList.Send.Request(body: requestBody, itemUuid: itemUUID)
        interactor.sendNoteToItem(request: request)
    }
    
    func addToCollection() {
        guard let itemUUID = dataStore.item?.uuid,
              let collectionItemUUID = dataStore.collectionSelected?.uuid else {
                  dataStore.alertType = .actionFailed
                  if dataStore.item == nil {
                      dataStore.alertMessage = LocalizedStringKey("Item not found")
                  } else {
                      dataStore.alertMessage = LocalizedStringKey("Collection not selected")
                  }
                  
                  dataStore.shouldShowToast = true
                  
                  return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        let collectionNote = dataStore.collectionNoteInputText
        let requestBody = Collections.SendItems.Request.CollectionRequestBody(itemUUID: itemUUID, note: collectionNote)
        let requestReview = Collections.SendItems.Request(body: requestBody, collectionUUID: collectionItemUUID)
        interactor.sendItemToCollection(request: requestReview)
    }
    
    func delete() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        switch reviewTypeSelected {
        case .rate:
            let request = Review.Delete.Request(itemUUID: itemUUID)
            interactor.deleteRate(request: request)
        case .review:
            let request = FullReview.Delete.Request(itemUUID: itemUUID)
            interactor.deleteReview(request: request)
        case .collection:
            guard let collectionItemUUID = dataStore.collectionSelected?.uuid else {
                dataStore.alertType = .actionFailed
                dataStore.alertMessage = LocalizedStringKey("Collection not selected")
                dataStore.shouldShowToast = true
                return
            }
            
            let request = Collections.DeleteItems.Request(collectionUUID: collectionItemUUID, itemUUID: itemUUID)
            interactor.deleteItemInCollection(request: request)
        case .progressNote, .posts: break
            // no-op
        }
    }
    
    func fetch(itemUUID: String?, andUpdate shouldUpdate: Bool = false, andOpen shouldOpen: Bool = false) {
        guard let itemUUID else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        if shouldOpen {
            if let apiUrl = item.apiUrl,
               var url = URL(string: apiUrl) {
                url.deleteLastPathComponent()
                let newUrl = url.absoluteString + itemUUID
                let request = Review.LoadSeason.Request(apiURL: newUrl)
                interactor.loadSeason(request: request)
            }
            return
        } else if shouldUpdate {
            if let apiUrl = item.apiUrl,
               var url = URL(string: apiUrl) {
                url.deleteLastPathComponent()
                let newUrl = url.absoluteString + itemUUID
                let request = Review.Update.Request(apiURL: newUrl, itemClass: TVShowSchema.self)
                interactor.update(request: request)
            }
            return
        }
        
        switch reviewTypeSelected {
        case .rate:
            let request = Review.Load.Request(itemUUID: itemUUID)
            interactor.loadRate(request: request)
        case .review:
            let request = FullReview.Load.Request(itemUUID: itemUUID)
            interactor.loadReview(request: request)
        case .collection, .progressNote, .posts:
            return
        }
    }
    
    func fetchPosts(itemUUID: String?, andTypes types: [String] = ["comment", "review", "collection", "mark","note"]) {
        guard let itemUUID else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowToast = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowToast = true
            return
        }
        
        switch reviewTypeSelected {
        case .posts:
            let request = CatalogPostsModel.Load.Request(typeList: types, itemUuid: itemUUID)
            interactor.loadPosts(request: request)
        default:
            return
        }
    }
}

extension ReviewView: ReviewFilterViewDelegate {
    func didPressShelfTypeButton(_ shelftype: ShelfType) {
        dataStore.shelfType = shelftype
    }
    
    func didPressVisibilityButton(_ visibility: Visibility) {
        dataStore.visibility = visibility
    }
    
    func didPressCrosspostSwitch(_ shouldCrosspost: Bool) {
        dataStore.shouldCrosspost = shouldCrosspost
    }
}

extension ReviewView: SimpleCollectionListViewDelegate {
    func didSelectCollection(_ collection: CollectionModel) {
        dataStore.collectionSelected = collection
    }
}

extension ReviewView: SimpleProgressNoteListViewDelegate {
    func didDeleteNote() {
        dataStore.noteListNeedsToUpdate = true
    }
    
    func didLoadNotes(_ notes: [NoteSchema]) {
        dataStore.noteList = notes
        dataStore.noteListNeedsToUpdate = false
    }
    
    func didTapEditNote(_ note: NoteSchema) {
        dataStore.noteSelected = note
        if let contentWarning = note.title {
            dataStore.progressNoteContentWarningInputText = contentWarning
        }
        dataStore.progressNoteInputText = note.content
        if let progressValue = note.progressValue {
            dataStore.progressNoteValueInputText = progressValue
        }
        selectedProgressType = progressTypeList.firstIndex { type in
            type == note.progressType
        } ?? selectedProgressType
        dataStore.visibility = Visibility(rawValue: note.visibility) ?? dataStore.visibility
    }
}

struct ReviewView: View {
    var interactor: ReviewBusinessLogic?
    var postInteractionInteractor: PostInteractionsInteractor?
    
    @FocusState private var commentIsFocused: Bool
    @FocusState private var titleIsFocused: Bool
    @FocusState private var collectionNoteIsFocused: Bool
    @FocusState private var progressNoteIsFocused: Bool
    @FocusState private var progressNoteValueIsFocused: Bool
    @FocusState private var progressNoteContentWarningIsFocused: Bool
    
    @Environment(\.showToast) private var showToast
    
    @State private var replyViewDetent = PresentationDetent.medium
    
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataStore: ReviewDataStore
    
    @State var selectedProgressType: Int = 0
    @State var reviewTypeSelected: ReviewType = .rate
    
    @State var isReviewTypeExpanded = false
    @State var isProgressTypeExpanded = false
    @State var isExternalLinksExpanded = false
    
    let rows = [
      GridItem(.adaptive(minimum: 100))
    ]
    
    let seasonRows = [
      GridItem(.adaptive(minimum: 30))
    ]
    
    var maximumRating = 5
    var poster: URL?
    
    var progressTypeList: [ItemCategory.progressNoteType] {
        item.category.availableProgressNoteTypes
    }
    
    var reviewTypeList: [ReviewType] {
        var list: [ReviewType] = [.rate, .review, .collection, .posts]
        if !item.category.availableProgressNoteTypes.isEmpty {
            list.append(.progressNote)
        }
        
        return list
    }
    
    var item: ItemViewModel {
        dataStore.item
    }
    
    var neoDBratingString: String {
        if let neoDBrating = dataStore.item.neoDBrating {
            return String(format: "%.2f", neoDBrating)
        }
        
        return "--"
    }
    
    var deleteButtonTitle: LocalizedStringKey {
        switch reviewTypeSelected {
        case .rate:
            return "Delete rate"
        case .review:
            return "Delete review"
        case .collection:
            return "Remove from collection"
        case .progressNote, .posts:
            return ""
        }
    }
    
    var actionButtonTitle: LocalizedStringKey {
        switch reviewTypeSelected {
        case .progressNote:
            if dataStore.noteSelected != nil {
                return "Update"
            } else {
                return "Add"
            }
        case .rate:
            if dataStore.shelfType != .wishlist {
                return "Rate"
            } else {
                return "Add"
            }
        case .review:
            return "Review"
        default:
            return "Add"
        }
    }
    
    private var commentViewLineLimit: Int {
        if UIDevice.current.userInterfaceIdiom == .pad || commentIsFocused {
            return 12
        }
        
        return 1
    }
    
    init(item: ItemViewModel, dataStore: ReviewDataStore = ReviewDataStore()) {
        if dataStore.item == nil {
            if let visibility = UserSettings.shared.userPreference?.defaultVisibility {
                dataStore.visibility = visibility
            }
            if let shelfType = item.shelfType {
                dataStore.shelfType = shelfType
            }
            if let selectedShelfType = item.shelfType?.rawValueInt() {
                dataStore.selectedShelfType = selectedShelfType
            }
            if let shouldCrosspost = UserSettings.shared.userPreference?.defaultCrosspost {
                dataStore.shouldCrosspost = shouldCrosspost
            }
            if let selectedVisibility = UserSettings.shared.userPreference?.defaultVisibility.rawValue {
                dataStore.selectedVisibility = selectedVisibility
            }
            dataStore.rating = (item.rating != nil) ? Double(item.rating!)/2.0 : nil
            dataStore.item = item
            dataStore.inputText = item.comment
        }
        self.dataStore = dataStore
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 8) {
                navigationButtons()
                if dataStore.state == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                } else if dataStore.state == .markdownEditor {
                    MarkdownEditorView($dataStore.bodyInputText, showPreview: $dataStore.showFullReviewMarkdownPreview)
                } else if dataStore.state == .full {
                    if commentIsFocused || reviewTypeSelected == .progressNote || reviewTypeSelected == .posts {
                        Text(item.localizedTitle)
                            .font(.title)
                            .bold()
                            .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
                    } else {
                        itemDetails()
                    }
                    
                    switch reviewTypeSelected {
                    case .rate:
                        if !commentIsFocused {
                            if !(item.seasonUuids ?? []).isEmpty {
                                seasonSelectionView()
                            }
                            if  dataStore.shelfType != .wishlist {
                                ratingView()
                            }
                        }
                        commentView()
                    case .review:
                        titleBodyView()
                    case .collection:
                        collectionNoteView()
                        SimpleCollectionListView($dataStore.collectionList, delegate: self, selectedCollectionModel: dataStore.collectionSelected).configureView()
                    case .progressNote:
                        contentWarningView()
                        progressTypeViewFilter()
                        commentNoteView()
                    case .posts:
                        if dataStore.posts.isEmpty {
                            EmptyView()
                                .safeAreaPadding(125)
                        } else {
                            timelineView
                        }
                    }
                    
                    if !commentIsFocused && !progressNoteIsFocused {
                        if reviewTypeSelected != .collection && reviewTypeSelected != .posts {
                            reviewFilter()
                        }
                        
                        switch reviewTypeSelected {
                        case .progressNote:
                            actionButton()
                            SimpleProgressNoteListView(item: item, noteList: dataStore.noteList, delegate: self, isLoaded: !dataStore.noteListNeedsToUpdate).configureView()
                                .padding(EdgeInsets(top: 8, leading: .zero, bottom: 8, trailing: .zero))
                        case .posts:
                            Spacer()
                        default:
                            bottomButtons()
                        }
                    }
                } else if dataStore.state == .description || dataStore.state == .poster {
                    itemDetails()
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 15, leading: .zero, bottom: .zero, trailing: .zero))
            .background(Color.reviewBackgroundColor)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        commentIsFocused = false
                        titleIsFocused = false
                        collectionNoteIsFocused = false
                        progressNoteIsFocused = false
                        progressNoteValueIsFocused = false
                        progressNoteContentWarningIsFocused = false
                    }
            )
            .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
                alertButtons()
            } message: {
                Text(dataStore.alertMessage ?? "Error")
            }
            .task {
                if shouldUpdateItem() {
                    fetch(itemUUID: item.uuid, andUpdate: true)
                }
                
                if shouldFetchRateItem() {
                    fetch(itemUUID: item.uuid)
                } else {
                    dataStore.state = .full
                }
            }
            .sheet(isPresented: $dataStore.showReplyView, onDismiss: {
                dataStore.postClicked = nil
                dataStore.replyPostClicked = nil
                dataStore.showReplyView = false
            }) {
                if let postClicked = dataStore.postClicked {
                    ReplyView(delegate: self, post: postClicked).configureView()
                        .presentationDetents(
                            [.medium, .large],
                            selection: $replyViewDetent
                        )
                } else if let replyPostClicked = dataStore.replyPostClicked {
                    ReplyView(delegate: self, reply: replyPostClicked).configureView()
                        .presentationDetents(
                            [.medium, .large],
                            selection: $replyViewDetent
                        )
                }
            }
            .fullScreenCover(isPresented: $dataStore.shouldPushToSeason, onDismiss: {
                dataStore.seasonSelected =  nil
                dataStore.shouldPushToSeason = false
            }) {
                if let item = dataStore.seasonSelected {
                    ReviewView(item: item, dataStore: dataStore.createNewReviewDataStore())
                        .configureView()
                }
            }
            .onChange(of: dataStore.shouldShowToast) {
                guard let alertMessage = dataStore.alertMessage,
                      dataStore.shouldShowToast else { return }
                switch dataStore.alertType {
                case .success:
                    showToast(.success(nil, alertMessage))
                default:
                    showToast(.failure(nil, alertMessage))
                }
                dataStore.shouldShowToast = false
            }
        }
        .background(Color.reviewBackgroundColor)
    }
    
    func alertButtons() -> some View {
        VStack {
            if dataStore.alertType == .delete {
                Button("Cancel", role: .cancel) {}
                Button("OK", role: .destructive) {
                    DispatchQueue.main.async {
                        delete()
                    }
                }
            } else {
                Button("OK", role: .cancel) {
                    switch dataStore.alertType {
                    case .deleteError, .actionFailed:
                        break
                    default:
                        dismiss()
                    }
                }
            }
        }
    }
    
    var hasSpecials: Bool  {
        (item.seasonUuids?.count ?? .zero) > item.seasonCount ?? .zero
    }
    
    func seasonSelectionView() -> some View {
        LazyVGrid(columns: seasonRows, alignment: .center) {
            ForEach(Array((item.seasonUuids ?? []).enumerated()), id: \.element) { index, uuid in
                Button(action: {
                    fetch(itemUUID: uuid, andOpen: true)
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.chihuClear)
                            .stroke(Color.chihuGreen, lineWidth: 1)
                            .frame(width: 30, height: 30)
                        if hasSpecials {
                            if index == 0 {
                                Text("#")
                                    .foregroundColor(.chihuGreen)
                            } else {
                                Text("\(index)")
                                    .foregroundColor(.chihuGreen)
                            }
                        } else {
                            Text("\(index + 1)")
                                .foregroundColor(.chihuGreen)
                        }
                    }
                })
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
    
    func shouldUpdateItem() -> Bool {
        switch item.category {
        case .tv, .tvSeason, .tvEpisode:
            if item.seasonUuids == nil {
                return true
            }
        default:
            break
        }
        
        return false
    }
    
    func shouldFetchRateItem() -> Bool {
        return item.comment.isEmpty || item.rating == .zero
    }
    
    func shouldFetchReviewItem() -> Bool {
        return  (item.reviewTitle ?? String()).isEmpty &&
                (item.reviewBody ?? String()).isEmpty
    }
    
    func reviewFilter() -> some View {
        ReviewFilterView(reviewTypeSelected: $reviewTypeSelected,
                         selectedVisibility: $dataStore.selectedVisibility,
                         selectedShelfType: $dataStore.selectedShelfType,
                         shouldCrosspost: $dataStore.shouldCrosspost,
                         delegate: self)
            .padding(EdgeInsets(top: .zero, leading: 4, bottom: .zero, trailing: 4))
    }
    
    func deleteAlert() {
        dataStore.alertType = .delete
        if reviewTypeSelected == .collection {
            dataStore.alertMessage = "Are you sure you want to remove your item from the collection?"
        } else {
            dataStore.alertMessage = "Are you sure you want to delete your review?"
        }
        dataStore.shouldShowAlert = true
    }
    
    func bottomButtons() -> some View {
        HStack {
            deleteButton()
            actionButton()
        }
    }
    
    func actionButton() -> some View {
        Button(actionButtonTitle) {
            switch reviewTypeSelected {
            case .rate:
                sendRate()
            case .review:
                sendReview()
            case .collection:
                addToCollection()
            case .progressNote:
                if dataStore.noteSelected != nil {
                    updateNote()
                } else {
                    addNewNote()
                }
            case .posts:
                return
            }
        }
        .chihuButtonStyle()
        .tint(.reviewActionButtonColor)
        .padding(8)
    }
    
    func deleteButton() -> some View {
        Button(deleteButtonTitle) {
            deleteAlert()
        }
        .chihuButtonStyle()
        .tint(.reviewDeleteButtonColor)
        .padding(8)
    }
    
    func closeButton() -> some View {
        ZStack {
            Circle()
                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .font(Font.body.weight(.bold))
                .scaleEffect(0.416)
                .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
        }
    }
    
    func navigationButtons() -> some View {
        VStack {
            HStack {
                Button(action: {
                    if dataStore.state == .full &&
                        !commentIsFocused &&
                        reviewTypeSelected == .progressNote &&
                        dataStore.noteSelected != nil {
                        resetNoteView()
                    } else if dataStore.state != .full || commentIsFocused {
                        commentIsFocused = false
                        dataStore.state = .full
                    } else {
                        dismiss()
                    }
                }) {
                    closeButton()
                }
                .frame(width: 30, height: 30)
                Spacer()
                if dataStore.state == .full && !commentIsFocused {
                    Button(reviewTypeSelected.rawValue) {
                        withAnimation { isReviewTypeExpanded = !isReviewTypeExpanded }
                    }
                    .chihuButtonStyle()
                    .tint(.reviewFilterButtonSelectedColor)
                    Spacer()
                    if let externalResources = dataStore.item.externalResources,
                       !externalResources.isEmpty && reviewTypeSelected != .posts {
                        Button(action: {
                            withAnimation { isExternalLinksExpanded = !isExternalLinksExpanded }
                        }) {
                            Image(systemName: "arrow.up.right.square")
                                .resizable()
                                .frame(width: 30, height:  30)
                        }
                        .frame(width: 30, height: 30)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 30, height: 30)
                    }
                } else if dataStore.state == .markdownEditor {
                    let previewButtonName = LocalizedStringKey(dataStore.showFullReviewMarkdownPreview ? "Preview On" : "Preview Off")
                    Button(previewButtonName) {
                        withAnimation { dataStore.showFullReviewMarkdownPreview = !dataStore.showFullReviewMarkdownPreview }
                    }
                    .chihuButtonStyle()
                    .tint(buttonPreviewMarkdownColor())
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
            if dataStore.state != .markdownEditor {
                if isReviewTypeExpanded {
                    LazyVGrid(columns: rows) {
                        ForEach(reviewTypeList.indices, id: \.self) { index in
                            Button(reviewTypeList[index].rawValue) {
                                reviewTypeSelected = reviewTypeList[index]
                                withAnimation { isReviewTypeExpanded = !isReviewTypeExpanded }
                                if shouldFetchReviewItem() && reviewTypeSelected == .review {
                                    fetch(itemUUID: item.uuid)
                                    dataStore.state = .loading
                                }
                                
                                if reviewTypeSelected == .posts {
                                    fetchPosts(itemUUID: item.uuid)
                                    dataStore.state = .loading
                                }
                            }
                            .chihuButtonStyle()
                            .tint(buttonReviewTypeColor(type: reviewTypeList[index]))
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                } else if isExternalLinksExpanded, let externalResources = dataStore.item.externalResources {
                    VStack(spacing: 1) {
                        ForEach(externalResources) { link in
                            linkCell(name: UrlCleaner.keepSiteName(from: link.url), url: link.url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
    }
    
    func linkCell(name: String, url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            HStack {
                Spacer()
                Text(name)
                    .multilineTextAlignment(.center)
                    .frame(height: 35)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .tint(Color.externalResourcesReviewViewRowBackgroundColor)
        .foregroundColor(Color.chihuBlack)
    }
    
    func buttonReviewTypeColor(type: ReviewType) -> Color {
        type == reviewTypeSelected ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonPreviewMarkdownColor() -> Color {
        dataStore.showFullReviewMarkdownPreview ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func ratingView() -> some View {
        VStack {
            if UserSettings.shared.showNeoDBscore {
                HStack {
                    Text("🧩")
                        .font(.system(size: 14))
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .minimumScaleFactor(0.1)
                    Text(neoDBratingString)
                        .fontWeight(.bold)
                        .foregroundColor(.chihuBlack)
                        .scaledToFit()
                        .minimumScaleFactor(0.1)
                }
            }
            HStack {
                EmoticonView($dataStore.rating)
                RatingView($dataStore.rating, maxRating: 5)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.chihuYellow)
                    .padding()
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 30, bottom: .zero, trailing: 30))
    }
    
    func commentView() -> some View {
        VStack {
            TextField(textFieldPlaceHolder(), text: $dataStore.inputText, axis: .vertical)
                .focused($commentIsFocused)
                .lineLimit(commentViewLineLimit, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
            if commentIsFocused {
                HStack {
                    Spacer()
                    Text("\(dataStore.inputText.count) / 360")
                        .foregroundColor(textFieldCharactersCounterColor())
                }
                .padding(.trailing, 8)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    func titleBodyView() -> some View {
        VStack(spacing: 8) {
            TextField("Title", text: $dataStore.titleInputText, axis: .vertical)
                .focused($titleIsFocused)
                .lineLimit(1, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
            Button {
                dataStore.state = .markdownEditor
            } label: {
                TextField("Body", text: $dataStore.bodyInputText, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(8, reservesSpace: true)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
                    .disabled(true)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    private func textFieldCharactersCounterColor() -> Color {
        if dataStore.inputText.count > 360 {
            return .chihuRed
        } else {
            return .chihuBlack
        }
    }
    
    func collectionNoteView() -> some View {
        VStack {
            TextField("Please type the collection note for this item", text: $dataStore.collectionNoteInputText, axis: .vertical)
                .focused($collectionNoteIsFocused)
                .lineLimit(2, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    private func textFieldPlaceHolder() -> LocalizedStringKey {
        if commentIsFocused {
            "Please type your comments here \nTips: use >!text!< for spoilers \nsome instances may not be able to show posts longer than 360 characters."
        } else {
            "Please type your comments here"
        }
    }
    
    func itemDetails() -> some View {
        VStack {
            Text(item.localizedTitle)
                .font(.title)
                .bold()
            HStack {
                if dataStore.state == .full {
                    Button {
                        dataStore.state = .poster
                    } label: {
                        CachedAsyncImage(url: item.poster) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 140)
                                    .cornerRadius(8)
                            default:
                                Image("ImagePlaceHolder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 140)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    if let description = item.localizedDescription {
                        Button {
                            dataStore.state = .description
                        } label: {
                            Text(description)
                                .multilineTextAlignment(.leading)
                                .frame(height: 140)
                                .padding(EdgeInsets(top: .zero, leading: 8, bottom: .zero, trailing: 8))
                                .foregroundColor(.chihuBlack)
                        }
                    }
                } else if dataStore.state == .description, let description = item.localizedDescription {
                    Button {
                        dataStore.state = .full
                    } label: {
                        Text(description)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: .zero, trailing: 8))
                            .foregroundColor(.chihuBlack)
                    }
                } else if dataStore.state == .poster {
                    Button {
                        dataStore.state = .full
                    } label: {
                        CachedAsyncImage(url: item.poster) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Image("ImagePlaceHolder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
    }
    
    private func updateNote(withNote note: NoteSchema) {
        if let index = dataStore.noteList.firstIndex(where: { noteFromList in
            noteFromList.id == note.id
        }) {
            dataStore.noteList[index] = note
        }
    }
    
    private func updateView(withItem item: ItemViewModel) {
        dataStore.item = ItemViewModelBuilder.update(oldItem: dataStore.item, withItem: item)
        
        dataStore.rating = dataStore.item.rating != nil ? (Double(dataStore.item.rating!)/2.0) : nil
        dataStore.inputText = dataStore.item.comment
        if let shelfType = dataStore.item.shelfType {
            dataStore.selectedShelfType = shelfType.rawValueInt()
        }
    }
    
    private func updateView(withReview item: ItemViewModel) {
        var newItem = dataStore.item
        
        if let reviewTitle = item.reviewTitle,  dataStore.titleInputText.isEmpty {
            newItem?.reviewTitle = item.reviewTitle
            dataStore.titleInputText = reviewTitle
        }
        
        if let reviewBody = item.reviewBody, dataStore.bodyInputText.isEmpty {
            dataStore.bodyInputText = reviewBody
            newItem?.reviewBody = item.reviewBody
        }
        
        dataStore.item = newItem
    }
    
    private func resetNoteView() {
        dataStore.noteSelected = nil
        dataStore.progressNoteContentWarningInputText = String()
        dataStore.progressNoteInputText = String()
        dataStore.progressNoteValueInputText = String()
    }
}

// Posts

extension ReviewView {
    var timelineView: some View {
        VStack(alignment: .leading) {
            ForEach(dataStore.posts) { post in
                CellTimeline(post: post, image: ImageState.none, avatarImage: ImageState.needsLoading, delegate: self)
                    .padding(.horizontal, 10)
                Divider()
            }
        }
        .background(Color.postListBackgroundColor)
    }
}

extension ReviewView: CellTimelineDelegate {
    func didPressRepost(on post: TootSDK.Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            dataStore.shouldShowToast = true
            return
        }

        let likeRequest = PostInteraction.Repost.Request(postId: post.id, reposted: post.reposted ?? false)
        postInteractionInteractor.repost(request: likeRequest)
    }
    
    func editError() {
        DispatchQueue.main.async {
            dataStore.shouldShowAlert = true
            dataStore.alertMessage = "Invalid url"
        }
    }
    
    func didPressUpdate(on post: Post) {
        DispatchQueue.main.async {
            dataStore.replyPostClicked = post
            dataStore.showReplyView = true
        }
    }
    
    func didPressLike(on post: Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            dataStore.shouldShowToast = true
            return
        }

        let likeRequest = PostInteraction.LikeDislike.Request(postId: post.id, favourited: post.favourited ?? false)
        postInteractionInteractor.likeDislike(request: likeRequest)
    }
    
    func didPressReply(on post: Post) {
        DispatchQueue.main.async {
            dataStore.postClicked = post
            dataStore.showReplyView = true
        }
    }
    
    func handleURL(_ url: URL) {
        URLHandler.handleItemURL(url) { item in
            if let item {
                DispatchQueue.main.async {
                    fetch(itemUUID: item.uuid, andOpen: true)
                }
            } else {
                openURL(url)
            }
        }
    }
}

extension ReviewView: ReplyDelegate {
    func didEndReply(with post: Post) {
        DispatchQueue.main.async {
            dataStore.showReplyView = false
            let index = dataStore.posts.firstIndex {
                $0.id == post.id
            }
            
            if let index {
                dataStore.posts[index] = post
            } else {
                dataStore.posts.insert(post, at: 0)
            }
        }
    }
}

extension ReviewView {
    private func contentWarningView() -> some View {
        VStack {
            TextField("Content Warning (optional)", text: $dataStore.progressNoteContentWarningInputText, axis: .vertical)
                .focused($progressNoteContentWarningIsFocused)
                .lineLimit(2, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    private func progressTypeViewFilter() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button(progressTypeList[selectedProgressType].buttonName()) {
                    withAnimation {
                        isProgressTypeExpanded = !isProgressTypeExpanded
                    }
                }
                .chihuButtonStyle()
                .tint(.filterButtonSelectedColor)
                TextField("Progress (optional)", text: $dataStore.progressNoteValueInputText, axis: .vertical)
                    .focused($progressNoteValueIsFocused)
                    .lineLimit(1, reservesSpace: true)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
            }
            if isProgressTypeExpanded {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(progressTypeList.indices, id: \.self) { index in
                        Button(progressTypeList[index].buttonName()) {
                            selectedProgressType = index
                        }
                        .chihuButtonStyle()
                        .tint(buttonProgressTypeColor(index: index))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    private func buttonProgressTypeColor(index: Int) -> Color {
        index == selectedProgressType ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    private func commentNoteView() -> some View {
        VStack {
            TextField("Please type the progress note for this item", text: $dataStore.progressNoteInputText, axis: .vertical)
                .focused($progressNoteIsFocused)
                .lineLimit(progressNoteIsFocused ? 12 : 2, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.reviewCommentBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let shelfItemTitle = LocalizedTitleSchema(lang: "en", text: "Harold and the Purple Crayon")
        let shelfItemDescription = LocalizedTitleSchema(lang: "en", text: "Inside of his book, adventurous Harold can make anything come to life simply by drawing it. After he grows up and draws himself off the book's pages and into the physical world, Harold finds he has a lot to learn about real life.")
        let shelfItemDetails = ItemSchema(id: "1", type: String(), uuid: "2", url: String(), apiUrl: String(), category: .movie, parentUuid: nil, displayTitle: String(), externalResources: [], title: nil, description: nil, localizedTitle: [shelfItemTitle], localizedDescription: [shelfItemDescription], coverImageUrl: URL(string: "https://eggplant.place/m/item/imdb/2024/08/26/641cea4b-def0-489d-b994-05c421b6c804.jpg"), rating: nil, ratingCount: nil, brief: String(), origTitle: nil, language: [])
        let shelfItem = ShelfItem(shelfType: .complete, item: shelfItemDetails, ratingGrade: 3, commentText: "bom", title: nil, body: nil)
        let shelfViewModel = ItemViewModelBuilder.create(from: shelfItem)
        
        return ReviewView(item: shelfViewModel)
    }
}
