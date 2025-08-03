//
//  SearchUrlView.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/12/24.
//  
//
import SwiftUI

extension SearchUrlView: SearchDisplayLogic {
    func displayResultFromGoogleBooksName(viewModel: SearchByNameGoogleBooks.Load.ViewModel) {
        // no-op
    }
    
    func displayResultFromPIname(viewModel: SearchByNamePI.Load.ViewModel) {
        // no-op
    }
    
    func displayResultFromTMDBname(viewModel: SearchByNameTMDB.Load.ViewModel) {
        // no-op
    }
    
    func displayResultFromName(viewModel: SearchByName.Load.ViewModel) {
        // no-op
    }
    
    func displayResultFromURL(viewModel: SearchByURL.Load.ViewModel) {
        // no-op
    }
    
    func openResultFromURL(viewModel: SearchByURL.Load.ViewModel) {
        DispatchQueue.main.async {
            openItem(viewModel.shelfItemsViewModel)
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            guard let interactor else {
                dataStore.state = .error(ChihuError.codeError)
                return
            }
            
            dataStore.shelfItemsViewModel = nil
            if let chihuError = error as? ChihuError {
                switch chihuError {
                case .fetchInProgress:
                    let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: ItemSchema.self)
                    interactor.loadFromURLAndOpen(request: requestShelfs)
                case .tryAgainLater:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let lastCount = dataStore.tryAgainCounter[url.absoluteString] ?? 0
                        if lastCount < 2 {
                            dataStore.tryAgainCounter = [url.absoluteString: lastCount+1]
                            let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: ItemSchema.self)
                            interactor.loadFromURLAndOpen(request: requestShelfs)
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
    
    func fetch() {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let requestShelfs = SearchByURL.Load.Request(url: url, itemClass: ItemSchema.self)
        interactor.loadFromURLAndOpen(request: requestShelfs)
    }
}

struct SearchUrlView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var interactor: SearchBusinessLogic?
    
    @State private var url: URL
    @ObservedObject var dataStore = SearchUrlDataStore()
    
    public init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack {
            switch dataStore.state {
            case .loading:
                navigationButtons()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
            case .openReview:
                if let item = dataStore.shelfItemsViewModel {
                    LightReviewView(item: item)
                        .configureView()
                } else {
                    navigationButtons()
                    ErrorView(error: ChihuError.unknown)
                }
            case .error:
                navigationButtons()
                errorView(dataStore.state)
            }
        }
        .tint(.shareSheetLoadingColor)
        .background(Color.shareSheetBackgroundColor)
        .task {
            fetch()
        }
    }
    
    func navigationButtons() -> some View {
        VStack {
            HStack {
                Button(action: {
                    close()
                }) {
                    closeButton()
                }
                .frame(width: 30, height: 30)
                Spacer()
            }
        }
        .padding(20)
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
        dataStore.shelfItemsViewModel = item
        dataStore.state = .openReview
    }
    
    func errorView(_ errorState: SearchUrlState) -> some View {
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
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
