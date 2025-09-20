//
//  CollectionsView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//  
//
import SwiftUI

protocol CollectionsDisplayLogic {
    func display(viewModel: Collections.Load.ViewModel)
    func displayMessage(_ message: String)
    func displayItems(viewModel: Collections.LoadItems.ViewModel)
    func displayError(_ error: Error)
    func displayErrorMessage(_ error: Error)
}

extension CollectionsView: CollectionsDisplayLogic {
    func displayErrorMessage(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowAlert = true
        }
    }
    
    func displayMessage(_ message: String) {
        DispatchQueue.main.async {
            dataStore.alertType = .success
            dataStore.alertMessage = LocalizedStringKey(message)
            dataStore.shouldShowAlert = true
        }
    }
    
    func displayItems(viewModel: Collections.LoadItems.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.data.isEmpty {
                if let collectionSection = dataStore.selectedCollection {
                    collectionSection.items += viewModel.data
                    collectionSection.pages = viewModel.pages
                    collectionSection.count = viewModel.count
                    collectionSection.currentPage += 1
                    dataStore.selectedCollection = collectionSection
                    dataStore.state = .loaded
                } else {
                    dataStore.state = .error(ChihuError.unknown)
                    dataStore.selectedCollection = nil
                }
            } else {
                dataStore.state = .loaded
                dataStore.selectedCollection = nil
            }
        }
    }
    
    func display(viewModel: Collections.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.items.isEmpty {
                dataStore.collectionSectionList = viewModel.items.map {
                    CollectionSection(isSelected: false,
                                      uuid: $0.uuid,
                                      title: $0.title,
                                      description: $0.brief)
                }
                dataStore.count = viewModel.count // Needs load more logic
                dataStore.pages = viewModel.pages
                dataStore.state = .loaded
            } else {
                dataStore.state = .loaded
            }
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            if let _ = error as? ChihuError {
                dataStore.state = .error(error)
            } else {
                dataStore.state = .error(ChihuError.api(error: error))
            }
        }
    }
    
    func fetch() {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let request = Collections.Load.Request(page: 1)
        interactor.load(request: request)
    }
    
    func fetch(collection: CollectionSection) {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        let nextPage = collection.currentPage + 1
        let request = Collections.LoadItems.Request(collectionUUID: collection.uuid, page: nextPage)
        interactor.loadItem(request: request)
    }
    
    func getCollectionSection(from uuid: String) -> CollectionSection? {
        return dataStore.collectionSectionList.first { $0.uuid == uuid }
    }
    
    func deleteCollection(uuid: String) {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let request = Collections.Delete.Request(uuid: uuid)
        interactor.delete(request: request)
    }
}

extension CollectionsView: NewCollectionDelegate {
    func didEndCreation() {
        dataStore.showNewCollection = false
    }
}

struct CollectionsView: View {
    var interactor: CollectionsBusinessLogic?
    
    @Environment(\.reviewItem) private var reviewItem
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var dataStore: CollectionsDataStore
    
    @State private var newCollectionDetent = PresentationDetent.medium
        
    init(dataStore: CollectionsDataStore = CollectionsDataStore()) {
        self.dataStore = dataStore
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                switch dataStore.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                        .task(id: UUID()) {
                            fetch()
                        }
                case .loaded:
                    if dataStore.collectionSectionList.isEmpty {
                        GeometryReader { geometry in
                          ScrollView(.vertical) {
                              EmptyView()
                              .frame(minHeight: geometry.size.height)
                          }
                        }
                        .refreshable {
                            fetch()
                        }
                    } else {
                        List {
                            ForEach(dataStore.collectionSectionList) { collection in
                                VStack {
                                    textCell(collection: collection)
                                    if isSelected(collection) {
                                        if collection.items.isEmpty {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .scaleEffect(1)
                                                .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                                                .task {
                                                    fetch(collection: collection)
                                                }
                                        } else {
                                            GridContentView(delegate: self, cards: getCards(collection))
                                                .frame(minHeight: getGridHeight(numItems: collection.items.count))
                                        }
                                    }
                                }
                                .listRowBackground(Color.collectionViewRowBackgroundColor)
                                .swipeActions(edge: .leading) {
                                    Button("Edit") {
                                        dataStore.editCollection = collection
                                        dataStore.showNewCollection = true
                                    }
                                    .tint(.chihuBlue)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Delete") {
                                        deleteCollection(uuid: collection.uuid)
                                    }
                                    .tint(.chihuRed)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            fetch()
                        }
                    }
                case .error(let error):
                    GeometryReader { geometry in
                      ScrollView(.vertical) {
                          errorView(error)
                          .frame(minHeight: geometry.size.height)
                      }
                    }
                    .refreshable {
                        fetch()
                    }
                }
            }
            .navigationTitle("Collections")
            .background(Color.collectionViewBackgroundColor)
            .toolbarBackground(Color.collectionViewBackgroundColor, for: .navigationBar)
            .toolbar {
                Button {
                    dataStore.showNewCollection = true
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 25, height:  25)
                }
            }
            .sheet(isPresented: $dataStore.showNewCollection, onDismiss: {
                dataStore.editCollection = nil
                dataStore.showNewCollection = false
                fetch()
            }) {
                NewCollectionView(delegate: self, collection: dataStore.editCollection).configureView()
                    .presentationDetents(
                        [.medium, .large],
                        selection: $newCollectionDetent
                    )
            }
            .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
                Button("OK", role: .cancel) {
                    fetch()
                }
            } message: {
                Text(dataStore.alertMessage ?? "Error")
            }
            .onAppear {
                UIRefreshControl.appearance().tintColor = UIColor(Color.chihuGreen)
            }
        }
    }
    
    func getCards(_ collection: CollectionSection) -> [Card] {
        collection.items.asShelfItems().asCards()
    }
    
    func getGridHeight(numItems: Int) -> CGFloat {
        var itemPerLine: Int
        let device = UIDevice.current
        if device.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
            itemPerLine = 3
        } else {
            if device.orientation.isPortrait {
                itemPerLine = 6
            } else {
                itemPerLine = 10
            }
        }
        
        var numLines = numItems/itemPerLine
        if (numItems % itemPerLine) > 0 {
            numLines += 1
        }
        let height = numLines * 200
        
        return CGFloat(height)
    }
    
    func isSelected(_ collection: CollectionSection) -> Bool {
        dataStore.selectedCollection?.uuid == collection.uuid
    }
    
    func textCell(collection: CollectionSection) -> some View {
        Button {
            if isSelected(collection) {
                dataStore.selectedCollection = nil
            } else {
                dataStore.selectedCollection = collection
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(collection.title)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.chihuBlack)
                    if let description = collection.description {
                        Text(description)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.chihuGray)
                    }
                }
                Spacer()
            }
        }
        .tint(Color.chihuBlack)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func errorView(_ error: Error) -> some View {
        if let apiError = error as? ChihuError {
            if case ChihuError.api(error: let error) = apiError {
                return ErrorView(error: error)
            } else {
                return ErrorView(error: apiError)
            }
        }
        return ErrorView(error: error)
    }
}

extension CollectionsView: GridContentViewDelegate {
    func shouldLoadMore() -> Bool {
        if let collection = dataStore.selectedCollection {
            let serverCount = collection.count
            let localCount = collection.items.count
            
            return localCount < serverCount
        }
        
        return false
    }
    
    func loadMore() {
        if let collection = dataStore.selectedCollection {
            fetch(collection: collection)
        }
    }
    
    func didTapCard(_ card: Card) {
        let selectedCollection = dataStore.selectedCollection
        guard let collectionItemData = (selectedCollection?.items.first { $0.item.uuid == card.uuid }) else {
            dataStore.state = .error(ChihuError.didTapCardFailed)
            return
        }
        let shelfItem = ItemViewModelBuilder.create(from: collectionItemData.item)
        
        reviewItem(.review(shelfItem))
    }
    
    func resetList() {
        //no-op
    }
}

struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        return CollectionsView()
    }
}
