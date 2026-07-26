//
//  ShelfListFilterView.swift
//  Chihu
//
//

import SwiftUI

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
                for item in viewModel.shelfItemsViewModel {
                    dataStore.shelfItemsViewModel.append(item)
                }
                dataStore.count += viewModel.count
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
    
    func fetchAll(type: ShelfType, category: ItemCategory.shelfAvailable, andPage page: Int) {
        guard dataStore.state == .canLoad || dataStore.state == .firstLoad else {
            dataStore.objectWillChange.send()
            return
        }

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
        interactor.loadAll(request: requestShelfs)
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
                sorterView
                    .frame(alignment: .top)
                switch dataStore.state {
                case .error:
                    ErrorView(error: dataStore.lastError)
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                default:
                    GridContentView(delegate: self, cards: dataStore.sortedShelfItemsViewModel.asCards())
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
    
    var sorterView: some View {
        HStack(spacing: 0) {
            HStack(alignment: .center) {
                orderByDateButton()
                    .frame(width: 35)
                orderByRateButton()
                    .frame(width: 35)
                orderByNameButton()
                    .frame(width: 35)
                Spacer()
                    .frame(width: 8)
            }
            .border(sortButtonColor(isHighlighted: dataStore.orderDescending), width: 0.5)
            ZStack {
                Rectangle()
                    .fill(sortButtonColor(isHighlighted: dataStore.orderDescending))
                Image(systemName: "arrow.up.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        dataStore.orderDescending.toggle()
                        fetchAll()
                    }
                    .foregroundColor(sortButtonColor(isHighlighted: !dataStore.orderDescending))
            }
            .frame(width: 35)
        }
        .foregroundColor(sortButtonColor(isHighlighted: dataStore.orderDescending))
        .frame(height: 35)
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
    
    func orderByDateButton() -> some View {
        orderButton(isEnabled: dataStore.shouldOrderByDate, systemName: "calendar")
        .onTapGesture {
            dataStore.shouldOrderByDate.toggle()
            dataStore.shouldOrderByRate = false
            dataStore.shouldOrderByName = false
            fetchAll()
        }
    }
    
    func orderByRateButton() -> some View {
        orderButton(isEnabled: dataStore.shouldOrderByRate, systemName: "star.fill")
        .onTapGesture {
            dataStore.shouldOrderByDate = false
            dataStore.shouldOrderByRate.toggle()
            dataStore.shouldOrderByName = false
            fetchAll()
        }
    }
    
    func orderByNameButton() -> some View {
        orderButton(isEnabled: dataStore.shouldOrderByName, systemName: "textformat")
        .onTapGesture {
            dataStore.shouldOrderByDate = false
            dataStore.shouldOrderByRate = false
            dataStore.shouldOrderByName.toggle()
            fetchAll()
        }
    }
    
    func orderButton(isEnabled: Bool, systemName: String) -> some View {
        HStack {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundColor(sortButtonColor(isHighlighted: isEnabled))
    }
    
    func sortButtonColor(isHighlighted: Bool) -> Color {
        isHighlighted ? .shelfListButtonHighlightedColor : .shelfListButtonNormalColor
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

    func fetch() {
        cleanResult()
        Task {
            fetch(type: shelfTypeList[selectedShelfType],
                  category: categoryList[selectedCategory],
                  andPage: dataStore.pages)
        }
    }
    
    func fetchAll() {
        Task {
            fetchAll(type: shelfTypeList[selectedShelfType],
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
        dataStore.orderDescending = true
        dataStore.shouldOrderByDate = true
        dataStore.shouldOrderByRate = false
        dataStore.shouldOrderByName = false
    }
    
    func buttonCategoryColor(index: Int) -> Color {
        index == selectedCategory ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonShelfTypeColor(index: Int) -> Color {
        index == selectedShelfType ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}
