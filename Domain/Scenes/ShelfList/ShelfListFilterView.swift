//
//  ShelfListFilterView.swift
//  Chihu
//
//

import SwiftUI
import SwiftData

protocol ShelfListDisplayLogic {
    func display(viewModel: ShelfList.Load.ViewModel)
    func displayError(_ error: Error)
}

extension ShelfListFilterView: ShelfListDisplayLogic {
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.lastError = error
            dataStore.state = .error
        }
    }
    
    func display(viewModel: ShelfList.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.shelfItemsViewModel.isEmpty {
                let isFirstPage = dataStore.pages == 1
                if isFirstPage {
                    dataStore.shelfItemsViewModel = viewModel.shelfItemsViewModel
                    dataStore.count = viewModel.count
                } else {
                    for item in viewModel.shelfItemsViewModel {
                        dataStore.shelfItemsViewModel.append(item)
                    }
                    dataStore.count += viewModel.count
                }
                dataStore.saveToCache(
                    items: viewModel.shelfItemsViewModel,
                    cacheKey: dataStore.currentCacheKey,
                    replacing: isFirstPage
                )
                dataStore.pages += 1
                if viewModel.pages < dataStore.pages {
                    dataStore.state = .noMorePages
                } else {
                    dataStore.state = .canLoad
                }
            } else {
                dataStore.state = .noMorePages
            }
        }
    }
    
    func fetch(type: ShelfType, category: ItemCategory.shelfAvailable, andPage page: Int) {
        guard dataStore.state == .canLoad || dataStore.state == .firstLoad else { return }
        
        guard let interactor else {
            dataStore.lastError = ChihuError.codeError
            dataStore.state = .error
            return
        }
        
        var categoryShelfAvailable: ItemCategory.shelfAvailable?
        if category != .allItems {
            categoryShelfAvailable = category
        }
        
        dataStore.state = .loading
        let requestShelfs = ShelfList.Load.Request(type: type, page: page, category: categoryShelfAvailable)
        interactor.load(request: requestShelfs)
    }
    
    func fetchMore(type: ShelfType, category: ItemCategory.shelfAvailable, andPage page: Int) {
        guard dataStore.state == .canLoad || dataStore.state == .firstLoad else { return }
        
        guard let interactor else {
            dataStore.lastError = ChihuError.codeError
            dataStore.state = .error
            return
        }
        
        var categoryShelfAvailable: ItemCategory.shelfAvailable?
        if category != .allItems {
            categoryShelfAvailable = category
        }
        
        let requestShelfs = ShelfList.Load.Request(type: type, page: page, category: categoryShelfAvailable)
        interactor.load(request: requestShelfs)
    }
}

extension ShelfListFilterView: GridContentViewDelegate {
    func resetList() {
        // no-op
    }
    
    func didTapCard(_ card: Card) {
        guard let item = (dataStore.shelfItemsViewModel.filter { $0.uuid == card.uuid }.first) else {
            dataStore.lastError = ChihuError.didTapCardFailed
            dataStore.state = .error
            return
        }
        
        openItem(item)
    }
    
    func shouldLoadMore() -> Bool {
        dataStore.state == .canLoad
    }
    
    func loadMore() {
        if dataStore.state == .canLoad {
            fetchMore(type: shelfTypeList[selectedShelfType],
                  category: categoryList[selectedCategory],
                  andPage: nextPage)
        }
    }
}

struct ShelfListFilterView: View {
    @Environment(\.reviewItem) private var reviewItem
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var dataStore: ShelfListDataStore
    
    var nextPage: Int {
        dataStore.pages
    }
    var interactor: ShelfListBusinessLogic?
    
    // Filter
    @State var isShelfTypeExpanded = false
    @State var isCategoryExpanded = false
    
    var selectedCategory: Int {
        dataStore.selectedCategory
    }
    var selectedShelfType: Int {
        dataStore.selectedShelfType
    }
    
    let shelfTypeList: [ShelfType] = [
        .complete, .wishlist, .progress, .dropped
    ]
    
    // Do not add all items, it will break the view
    let categoryList: [ItemCategory.shelfAvailable] = [
        .allItems, .movie, .tv, .book, .music, .game, .podcast, .performance
    ]
    
    let threeColumns = [
      GridItem(.flexible(minimum: 125)),
      GridItem(.flexible(minimum: 90)),
      GridItem(.flexible(minimum: 90))
    ]
    
    init(dataStore: ShelfListDataStore = ShelfListDataStore()) {
        self.dataStore = dataStore
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                filterView
                    .frame(alignment: .top)
                switch dataStore.state {
                case .error:
                    CompactErrorView(error: dataStore.lastError)
                    GridContentView(delegate: self, cards: dataStore.shelfItemsViewModel.asCards())
                default:
                    GridContentView(delegate: self, cards: dataStore.shelfItemsViewModel.asCards())
                }
            }
            .background(Color.searchViewColor)
            .navigationTitle("Shelf")
            .toolbar {
                Button {
                    dataStore.showCollectionsView = true
                } label: {
                    Image(systemName: "square.stack.3d.down.right")
                        .resizable()
                        .frame(width: 25, height:  25)
                }
            }
        }
        .fullScreenCover(isPresented: $dataStore.showCollectionsView, onDismiss: {
            dataStore.showCollectionsView = false
        }) {
            CollectionsView(dataStore: dataStore.collectionDataStore).configureView()
        }
        .task {
            dataStore.modelContext = modelContext
            fetch()
        }
        .onChange(of: dataStore.showSelection) {
            if let item = dataStore.selectedItem {
                reviewItem(.review(item))
                dataStore.selectedItem = nil
                dataStore.showSelection = false
            }
        }
    }
    
    var filterView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Shelf type")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(shelfTypeList[selectedShelfType].shelfTypeButtonName()) {
                        withAnimation {
                            isShelfTypeExpanded.toggle()
                        }
                    }
                    .chihuButtonStyle()
                    .tint(.filterButtonSelectedColor)
            }
            if isShelfTypeExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(shelfTypeList.indices, id: \.self) { index in
                        Button(shelfTypeList[index].shelfTypeButtonName()) {
                            dataStore.selectedShelfType = index
                            fetch()
                        }
                        .chihuButtonStyle()
                        .tint(buttonShelfTypeColor(index: index))
                    }
                }
            }
            HStack {
                Text("Categories")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(categoryList[selectedCategory].itemCategory!.buttonName()) {
                        withAnimation {
                            isCategoryExpanded.toggle()
                        }
                    }
                    .chihuButtonStyle()
                    .tint(.filterButtonSelectedColor)
            }
            if isCategoryExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(categoryList.indices, id: \.self) { index in
                        Button(categoryList[index].itemCategory!.buttonName()) {
                            dataStore.selectedCategory = index
                            fetch()
                        }
                        .chihuButtonStyle()
                        .tint(buttonCategoryColor(index: index))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16))
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
    
    func openItem(_ item: ItemViewModel) {
        dataStore.showSelection = true
        dataStore.selectedItem = item
    }
    
    var cacheKey: String {
        "\(shelfTypeList[selectedShelfType].rawValue)_\(categoryList[selectedCategory].rawValue)"
    }

    func fetch() {
        let key = cacheKey
        cleanResult()
        dataStore.currentCacheKey = key
        let cached = dataStore.loadFromCache(cacheKey: key)
        if !cached.isEmpty {
            dataStore.shelfItemsViewModel = cached
            dataStore.state = .canLoad
        }
        Task {
            fetch(type: shelfTypeList[selectedShelfType],
                  category: categoryList[selectedCategory],
                  andPage: dataStore.pages)
        }
    }
    
    func cleanResult() {
        dataStore.state = .firstLoad
        dataStore.shelfItemsViewModel = []
        dataStore.lastError = nil
        dataStore.selectedItem = nil
        dataStore.pages = 1
        dataStore.count = 0
    }
    
    func buttonCategoryColor(index: Int) -> Color {
        index == selectedCategory ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonShelfTypeColor(index: Int) -> Color {
        index == selectedShelfType ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}
