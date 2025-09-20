//
//  LightReviewView.swift
//  Chihu
//
//  Created by Dennis Nunes on 27/12/24.
//
//

import SwiftUI
import Combine

extension LightReviewView: ReviewDisplayLogic {
    func displayPosts(viewModel: CatalogPostsModel.Load.ViewModel) {
        // no-op
    }
    
    func update(rateViewModel: Review.Update.ViewModel?, noteViewModel: ProgressNoteList.Update.ViewModel?) {
        // no-op
    }
    
    func open(viewModel: Review.LoadSeason.ViewModel) {
        // no-op
    }
    
    func displayActionError(_ error: any Error) {
        // no-op
    }
    
    func displayDeleteError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .deleteError
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowAlert = true
        }
    }
    
    func display(rateViewModel: Review.Delete.ViewModel?, reviewViewModel: FullReview.Delete.ViewModel?, collectionsItemViewModel: Collections.DeleteItems.ViewModel?) {
        DispatchQueue.main.async {
            dataStore.alertType = .success
            dataStore.alertMessage = LocalizedStringKey(rateViewModel?.message ?? "Unknown Error")
            dataStore.shouldShowAlert = true
        }
    }
    
    func displayLoadingError(_ error: any Error) {
        print(error.localizedDescription)
        // TODO: Improve this with a better error handling, alert snapbar?
        dataStore.state = .full
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            print(error.localizedDescription)
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowAlert = true
        }
    }
    
    func display(rateViewModel: Review.Load.ViewModel?, reviewViewModel: FullReview.Load.ViewModel?) {
        DispatchQueue.main.async {
            if let rateViewModel {
                updateView(withRate: rateViewModel.shelfItemsViewModel)
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
            dataStore.alertType = .success
            dataStore.alertMessage = LocalizedStringKey(rateViewModel?.message ?? "Unknown Error")
            dataStore.shouldShowAlert = true
        }
    }
    
    func sendRate() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
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
    
    func delete() {
        guard let itemUUID = dataStore.item?.uuid else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        let request = Review.Delete.Request(itemUUID: itemUUID)
        interactor.deleteRate(request: request)
    }
    
    func fetch(itemUUID: String?) {
        guard let itemUUID else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Item not found")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }

        let request = Review.Load.Request(itemUUID: itemUUID)
        interactor.loadRate(request: request)
    }
}

extension LightReviewView: ReviewFilterViewDelegate {
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

struct LightReviewView: View {
    var interactor: ReviewBusinessLogic?
    
    @FocusState private var commentIsFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataStore = ReviewDataStore()
    
    @State var reviewTypeSelected: ReviewType = .rate
    
    let column = [
      GridItem(.flexible(minimum: 90))
    ]
    
    var maximumRating = 5
    var poster: URL?
    var item: ItemViewModel {
        dataStore.item
    }
    
    var deleteButtonTitle: LocalizedStringKey {
        return "Delete rate"
    }
    
    init(item: ItemViewModel) {
        dataStore.rating = item.rating != nil ? Double(item.rating!)/2.0 : nil
        dataStore.item = item
        dataStore.inputText = item.comment
        dataStore.state = .full
        dataStore.selectedVisibility = UserSettings.shared.userPreference?.defaultVisibility.rawValue ?? 0
        dataStore.shouldCrosspost = UserSettings.shared.userPreference?.defaultCrosspost ?? true
    }
    
    var body: some View {
        VStack(spacing: 8) {
            navigationButtons()
            if dataStore.state == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
            } else if dataStore.state == .full {
                Text(item.localizedTitle)
                    .font(.title)
                    .bold()
                if dataStore.shelfType != .wishlist  && !commentIsFocused {
                    ratingView()
                }
                commentView()
                if !commentIsFocused {
                    reviewFilter()
                    deleteButton()
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 15, leading: .zero, bottom: .zero, trailing: .zero))
        .background(Color.reviewBackgroundColor)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    commentIsFocused = false
                }
        )
        .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
            alertButtons()
        } message: {
            Text(dataStore.alertMessage ?? "Error")
        }
    }
    
    func alertButtons() -> some View {
        VStack {
            if dataStore.alertType == .delete {
                Button("Cancel", role: .cancel) {}
                Button("OK", role: .destructive) {
                    delete()
                }
            } else {
                Button("OK", role: .cancel) {
                    switch dataStore.alertType {
                    case .deleteError:
                        break
                    default:
                        closeShareSheet()
                    }
                }
            }
        }
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
        dataStore.alertMessage = "Are you sure you want to delete your review?"
        dataStore.shouldShowAlert = true
    }
    
    func deleteButton() -> some View {
        Button(deleteButtonTitle) {
            deleteAlert()
        }
        .chihuButtonStyle()
        .tint(.reviewDeleteButtonColor)
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
                    if dataStore.state != .full || commentIsFocused {
                        commentIsFocused = false
                        dataStore.state = .full
                    } else {
                        closeShareSheet()
                    }
                }) {
                    closeButton()
                }
                .frame(width: 30, height: 30)
                Spacer()
                if dataStore.state == .full && !commentIsFocused {
                    Spacer()
                    Button(action: {
                        sendRate()
                    }) {
                        if dataStore.shelfType != .wishlist && reviewTypeSelected == .rate {
                            Text("Rate")
                                .foregroundColor(.chihuGreen)
                        } else {
                            Text("Add")
                                .foregroundColor(.chihuGreen)
                        }
                    }
                    .frame(height: 30)
                }
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
    }
    
    func ratingView() -> some View {
        HStack {
            EmoticonView($dataStore.rating)
            RatingView($dataStore.rating, maxRating: 5)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.chihuYellow)
                .padding()
        }
        .padding(EdgeInsets(top: .zero, leading: 30, bottom: .zero, trailing: 30))
    }
    
    func commentView() -> some View {
        VStack {
            TextField(textFieldPlaceHolder(), text: $dataStore.inputText, axis: .vertical)
                .focused($commentIsFocused)
                .lineLimit(commentIsFocused ? 12 : 1, reservesSpace: true)
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
    
    private func textFieldCharactersCounterColor() -> Color {
        if dataStore.inputText.count > 360 {
            return .chihuRed
        } else {
            return .chihuBlack
        }
    }
    
    private func textFieldPlaceHolder() -> LocalizedStringKey {
        if commentIsFocused {
            "Please type your comments here \nTips: use >!text!< for spoilers \nsome instances may not be able to show posts longer than 360 characters."
        } else {
            "Please type your comments here"
        }
    }
    
    private func updateView(withRate item: ItemViewModel) {
        var newItem = dataStore.item
        newItem?.localizedTitle = item.localizedTitle
        newItem?.localizedDescription = item.localizedDescription
        newItem?.posterString = item.posterString
        newItem?.comment = item.comment
        newItem?.rating = item.rating
        newItem?.shelfTypeRawValue = item.shelfTypeRawValue
        dataStore.item = newItem
        
        dataStore.rating = item.rating != nil ? Double(item.rating!)/2.0 : nil
        dataStore.inputText = item.comment
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
    
    private func closeShareSheet() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}

struct LightReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let shelfItemTitle = LocalizedTitleSchema(lang: "en", text: "Harold and the Purple Crayon")
        let shelfItemDescription = LocalizedTitleSchema(lang: "en", text: "Inside of his book, adventurous Harold can make anything come to life simply by drawing it. After he grows up and draws himself off the book's pages and into the physical world, Harold finds he has a lot to learn about real life.")
        let shelfItemDetails = ItemSchema(id: "1", type: String(), uuid: "2", url: String(), apiUrl: String(), category: .movie, parentUuid: nil, displayTitle: String(), externalResources: [], title: nil, description: nil, localizedTitle: [shelfItemTitle], localizedDescription: [shelfItemDescription], coverImageUrl: URL(string: "https://eggplant.place/m/item/imdb/2024/08/26/641cea4b-def0-489d-b994-05c421b6c804.jpg"), rating: nil, ratingCount: nil, brief: String(), origTitle: nil, language: [])
        let shelfItem = ShelfItem(shelfType: .complete, item: shelfItemDetails, ratingGrade: 3, commentText: "bom", title: nil, body: nil)
        let shelfViewModel = ItemViewModelBuilder.create(from: shelfItem)
        
        return LightReviewView(item: shelfViewModel)
    }
}
