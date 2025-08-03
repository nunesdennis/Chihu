//
//  CollectionsInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//  
//
import Foundation

protocol CollectionsBusinessLogic {
    func load(request: Collections.Load.Request)
    func delete(request: Collections.Delete.Request)
    func loadItem(request: Collections.LoadItems.Request)
}

final class CollectionsInteractor {
    var presenter: CollectionsPresentationLogic?
}

extension CollectionsInteractor: CollectionsBusinessLogic {
    func delete(request: Collections.Delete.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.deleteCollection(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentMessage(message: response.message)
            case .failure(let error):
                presenter?.presentErrorAlert(error: error)
            }
        }
    }
    
    func load(request: Collections.Load.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.fetchCollections(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func loadItem(request: Collections.LoadItems.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.fetchCollectionsItems(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentItems(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
