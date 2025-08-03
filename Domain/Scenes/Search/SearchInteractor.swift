//
//  SearchInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import Foundation

protocol SearchBusinessLogic {
    func loadFromNameGoogleBooks(request: SearchByNameGoogleBooks.Load.Request)
    func loadFromNameTMDB(request: SearchByNameTMDB.Load.Request)
    func loadFromNamePI(request: SearchByNamePI.Load.Request)
    func loadFromName(request: SearchByName.Load.Request)
    func loadFromURL(request: SearchByURL.Load.Request)
    func loadFromURLAndOpen(request: SearchByURL.Load.Request)
}

final class SearchInteractor {
    var presenter: SearchPresentationLogic?
}

extension SearchInteractor: SearchBusinessLogic {
    func loadFromNameGoogleBooks(request: SearchByNameGoogleBooks.Load.Request) {
        let worker = SearchNetworkingWorker()
        worker.fetchByNameGoogleBooks(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentResultFromGoogleBooksName(response:  response, category: request.category)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadFromNamePI(request: SearchByNamePI.Load.Request) {
        let worker = SearchNetworkingWorker()
        worker.fetchByNamePI(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentResultFromPIname(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadFromNameTMDB(request: SearchByNameTMDB.Load.Request) {
        let worker = SearchNetworkingWorker()
        worker.fetchByNameTMDB(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentResultFromTMDBname(response:  response, category: request.category)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadFromName(request: SearchByName.Load.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchByName(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentResultFromName(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadFromURL(request: SearchByURL.Load.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchByURL(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                let item = response.shelfItemDetails
                if item.itemClass == TVShowSchema.self {
                    worker.fetchWithApiURL(item.apiUrl, itemClass: TVShowSchema.self) { result in
                        switch result {
                        case .success(let item):
                            let response = SearchByURL.Load.Response.init(shelfItemDetails: item)
                            self.presenter?.presentResultFromURL(response:  response)
                        case .failure(let error):
                            self.presenter?.present(error: error)
                        }
                    }
                } else {
                    presenter?.presentResultFromURL(response:  response)
                }
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadFromURLAndOpen(request: SearchByURL.Load.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchByURL(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                let item = response.shelfItemDetails
                if item.itemClass == TVShowSchema.self {
                    worker.fetchWithApiURL(item.apiUrl, itemClass: TVShowSchema.self) { result in
                        switch result {
                        case .success(let item):
                            let response = SearchByURL.Load.Response.init(shelfItemDetails: item)
                            self.presenter?.presentResultFromURLAndOpen(response: response)
                        case .failure:
                            self.presenter?.presentResultFromURLAndOpen(response: response)
                        }
                    }
                } else {
                    presenter?.presentResultFromURLAndOpen(response: response)
                }
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
