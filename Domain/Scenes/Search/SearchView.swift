//
//  SearchView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import SwiftUI

extension SearchView: SearchDisplayLogic {
    func displayResultFromGoogleBooksName(viewModel: SearchByNameGoogleBooks.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.shelfItemsViewModel.isEmpty {
                for item in viewModel.shelfItemsViewModel {
                    dataStore.shelfItemsViewModel.append(item)
                }
                dataStore.count += viewModel.count
                dataStore.pages = viewModel.pages
                // TODO: changed from canLoadMore, infinity loading
                dataStore.state = .noMorePages
            } else if dataStore.pages == 0 {
                dataStore.state = .tryByURL
            } else {
                dataStore.state = .noMorePages
            }
        }
    }
    
    func displayResultFromPIname(viewModel: SearchByNamePI.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.shelfItemsViewModel.isEmpty {
                for item in viewModel.shelfItemsViewModel {
                    dataStore.shelfItemsViewModel.append(item)
                }
                dataStore.count += viewModel.count
                dataStore.pages = viewModel.pages
                // TODO: changed from canLoadMore, infinity loading
                dataStore.state = .noMorePages
            } else if dataStore.pages == 0 {
                dataStore.state = .tryByURL
            } else {
                dataStore.state = .noMorePages
            }
        }
    }
    
    func displayResultFromTMDBname(viewModel: SearchByNameTMDB.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.shelfItemsViewModel.isEmpty {
                for item in viewModel.shelfItemsViewModel {
                    dataStore.shelfItemsViewModel.append(item)
                }
                dataStore.count += viewModel.count
                dataStore.pages = viewModel.pages
                // TODO: changed from canLoadMore, infinity loading
                dataStore.state = .noMorePages
            } else if dataStore.pages == 0 {
                dataStore.state = .tryByURL
            } else {
                dataStore.state = .noMorePages
            }
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            guard let interactor else {
                dataStore.state = .error(ChihuError.codeError)
                return
            }
            
            if let chihuError = error as? ChihuError {
                switch chihuError {
                case .fetchInProgress:
                    if let lastItemTapped = dataStore.lastItemTapped {
                        didTapCard(lastItemTapped)
                    } else if let url = dataStore.lastURL {
                        let itemClass = dataStore.category.itemClass
                        let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: itemClass)
                        interactor.loadFromURL(request: requestShelfs)
                    } else {
                        dataStore.state = .error(ChihuError.api(error: error))
                    }
                case .tryAgainLater:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if let lastItemTapped = dataStore.lastItemTapped {
                            let lastCount = dataStore.tryAgainCounter[lastItemTapped.id] ?? 0
                            if lastCount < 2 {
                                dataStore.tryAgainCounter = [lastItemTapped.id: lastCount+1]
                                didTapCard(lastItemTapped)
                            } else {
                                dataStore.state = .error(ChihuError.api(error: error))
                            }
                        } else if let url = dataStore.lastURL {
                            let itemClass = dataStore.category.itemClass
                            let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: itemClass)
                            interactor.loadFromURL(request: requestShelfs)
                        } else {
                            dataStore.state = .error(ChihuError.api(error: error))
                        }
                    }
                default:
                    dataStore.state = .error(ChihuError.api(error: error))
                }
            } else {
                dataStore.state = .error(ChihuError.api(error: error))
            }
        }
    }
    
    func displayResultFromName(viewModel: SearchByName.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.shelfItemsViewModel.isEmpty {
                for item in viewModel.shelfItemsViewModel {
                    dataStore.shelfItemsViewModel.append(item)
                }
                dataStore.count += viewModel.count
                dataStore.pages = viewModel.pages
                // TODO: Improve this code bellow
                dataStore.state = .noMorePages
            } else if dataStore.pages == 0 {
                dataStore.state = .tryByURL
            } else {
                dataStore.state = .noMorePages
            }
        }
    }
    
    func displayResultFromURL(viewModel: SearchByURL.Load.ViewModel) {
        DispatchQueue.main.async {
            dataStore.shelfItemsViewModel.append(viewModel.shelfItemsViewModel)
            dataStore.count = 1
            dataStore.pages = 1
            dataStore.state = .noMorePages
        }
    }
    
    func openResultFromURL(viewModel: SearchByURL.Load.ViewModel) {
        DispatchQueue.main.async {
            openItem(viewModel.shelfItemsViewModel)
        }
    }
    
    func validUrL(urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
    
    func fetch() {
        guard (dataStore.state == .canLoad || dataStore.state == .firstLoad) && !searchText.isEmpty else { return }
        
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        dataStore.state = .loading
        if let url = URL(string: searchText), UIApplication.shared.canOpenURL(url) {
            dataStore.lastURL = url
            let itemClass = dataStore.category.itemClass
            let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: itemClass)
            interactor.loadFromURL(request: requestShelfs)
        } else {
            let category = dataStore.category.rawValue
            switch dataStore.source {
            case .instance:
                let requestShelfs = SearchByName.Load.Request(query: searchText, page: nextPage, category: category)
                interactor.loadFromName(request: requestShelfs)
            case .tmdb:
                let requestShelfs = SearchByNameTMDB.Load.Request(query: searchText, page: nextPage, category: category)
                interactor.loadFromNameTMDB(request: requestShelfs)
            case .googleBooks:
                let requestShelfs = SearchByNameGoogleBooks.Load.Request(query: searchText, category: category)
                interactor.loadFromNameGoogleBooks(request: requestShelfs)
            case .podcastIndex:
                let requestShelfs = SearchByNamePI.Load.Request(query: searchText)
                interactor.loadFromNamePI(request: requestShelfs)
            }
        }
    }
}

extension SearchView: GridContentViewDelegate {
    func resetList() {
        cleanResult()
    }
    
    func shouldLoadMore() -> Bool {
        dataStore.state == .canLoad
    }
    
    func loadMore() {
        if dataStore.state == .canLoad {
            fetch()
        }
    }
    
    func didTapCard(_ card: Card) {
        guard let item = (dataStore.shelfItemsViewModel.filter { $0.uuid == card.uuid }.first) else {
            dataStore.state = .error(ChihuError.didTapCardFailed)
            return
        }
        
        dataStore.lastItemTapped = card
        switch item.source {
        case .googleBooks, .tmdb, .podcastIndex:
            dataStore.state = .loading
            fetchByURLandOpenItem(item)
        case .instance:
            openItem(item)
        }
    }
}

struct SearchView: View {
    var interactor: SearchBusinessLogic?
    
    @Environment(\.reviewItem) private var reviewItem
    @ObservedObject var dataStore: SearchDataStore
    @StateObject var userSettings = UserSettings.shared
    @State private var searchText = ""
    @State private var isFocused = false
    var nextPage: Int {
        dataStore.pages + 1
    }
    
    init(dataStore: SearchDataStore = SearchDataStore()) {
        self.dataStore = dataStore
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                FilterView(category: $dataStore.category,
                           source: $dataStore.source)
                    .frame(alignment: .top)
                switch dataStore.state {
                case .firstLoad:
                    if isFocused || dataStore.isSourceExpanded || dataStore.isCategoryExpanded || userSettings.shouldHideTip {
                        gridContentView
                    } else {
                        TipView()
                    }
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                case .tryByURL:
                    ErrorView(error: ChihuError.noResultsTryURL)
                case .error:
                    errorView(dataStore.state)
                default:
                    gridContentView
                }
            }
            .navigationTitle("Search")
            .toolbar {
                if dataStore.category == .book {
                    Button {
                        searchText = String()
                        dataStore.showScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .resizable()
                            .frame(width: 25, height:  25)
                    }
                }
            }
            .background(Color.searchViewColor)
        }
        .searchable(text: $searchText, isPresented: $isFocused)
        .onChange(of: searchText.isEmpty, { searchCancelled() })
        .tint(.searchBarSearchViewButtonColor)
        .onAppear(perform: runSearch)
        .onSubmit(of: .search, runSearch)
        .onChange(of: dataStore.showSelection) {
            if let item = dataStore.selectedItem {
                reviewItem(.review(item))
                dataStore.lastItemTapped = nil
                dataStore.selectedItem = nil
                dataStore.showSelection = false
                dataStore.state = .noMorePages
            }
        }
        .fullScreenCover(isPresented: $dataStore.showScanner, onDismiss: {
            dataStore.showScanner = false
            dataStore.state = .canLoad
            fetch()
        }) {
            ScannerView(shouldStartScanning: $dataStore.showScanner, scannedText: $searchText)
        }
    }
    
    var gridContentView: some View {
        GridContentView(delegate: self, cards: dataStore.shelfItemsViewModel.asCards())
    }
    
    func searchCancelled() {
        if searchText.isEmpty && dataStore.state != .firstLoad {
            resetList()
        }
    }
    
    func runSearch() {
        cleanResult()
        Task {
            fetch()
        }
    }
    
    func cleanResult() {
        dataStore.state = .firstLoad
        dataStore.shelfItemsViewModel = []
        dataStore.pages = 0
        dataStore.count = 0
        dataStore.lastItemTapped = nil
        dataStore.lastURL = nil
    }
    
    func openItem(_ item: ItemViewModel) {
        dataStore.showSelection = true
        dataStore.selectedItem = item
    }
    
    func fetchByURLandOpenItem(_ item: ItemViewModel) {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        if let url = item.instanceFetchId, UIApplication.shared.canOpenURL(url) {
            let itemClass = dataStore.category.itemClass
            let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: itemClass)
            interactor.loadFromURLAndOpen(request: requestShelfs)
        }
    }
    
    func errorView(_ errorState: SearchState) -> some View {
        switch errorState {
        case .error(let errorReceived):
            if let apiError = errorReceived as? ChihuError {
                if case ChihuError.api(error: let error) = apiError {
                    return ErrorView(error: error)
                } else {
                    return ErrorView(error: apiError)
                }
            }
            return ErrorView(error: errorReceived)
        default:
            return ErrorView(error: ChihuError.unknown)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        return SearchView()
    }
}
