//
//  SimpleCollectionListView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//

import Foundation
import SwiftUI

extension SimpleCollectionListView: CollectionsDisplayLogic {
    func displayErrorMessage(_ error: any Error) {
        //no-op
    }
    
    func displayMessage(_ message: String) {
        //no-op
    }
    
    func displayItems(viewModel: Collections.LoadItems.ViewModel) {
        //no-op
    }
    
    func display(viewModel: Collections.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.items.isEmpty {
                collectionList = viewModel.items
                dataStore.count += viewModel.count
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
}

protocol SimpleCollectionListViewDelegate {
    func didSelectCollection(_ collection: CollectionModel)
}

struct SimpleCollectionListView: View {
    var interactor: CollectionsBusinessLogic?
    var delegate: SimpleCollectionListViewDelegate
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @ObservedObject var dataStore = CollectionsDataStore()
    @Binding var collectionList: [CollectionModel]
    
    init(_ collectionList: Binding<[CollectionModel]>, delegate: SimpleCollectionListViewDelegate, selectedCollectionModel: CollectionModel?) {
        _collectionList = collectionList
        self.delegate = delegate
        if !collectionList.isEmpty {
            dataStore.state = .loaded
        }
        if let selectedCollectionModel {
            dataStore.selectedCollectionModel = selectedCollectionModel
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            switch dataStore.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .task {
                        fetch()
                    }
            case .loaded:
                if collectionList.isEmpty {
                    Spacer()
                } else {
                    VStack(alignment: .leading) {
                        Text("Collections")
                            .font(.title3)
                            .bold()
                            .frame(alignment: .leading)
                            .padding(EdgeInsets(top: .zero, leading: 24, bottom: .zero, trailing: .zero))
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(collectionList) { item in
                                    textCell(collection: item)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            case .error(let error):
                errorView(error)
            }
        }
    }
    
    func getCellColor(for collection: CollectionModel) -> Color {
        if collection.uuid == dataStore.selectedCollectionModel?.uuid {
            return .simpleCollectionListViewSelectedRowBackgroundColor
        } else {
            return .simpleCollectionListViewRowBackgroundColor
        }
    }
    
    func textCell(collection: CollectionModel) -> some View {
        Button {
            delegate.didSelectCollection(collection)
            dataStore.selectedCollectionModel = collectionList.first {
                $0.uuid == collection.uuid
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(collection.title)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.chihuBlack)
                    if let description = collection.brief {
                        Text(description)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.chihuGray)
                    }
                }
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
        .background(getCellColor(for: collection))
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(Color.chihuBlack)
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

