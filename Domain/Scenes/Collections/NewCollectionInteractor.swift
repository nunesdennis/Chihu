//
//  NewCollectionInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation

protocol NewCollectionBusinessLogic {
    func send(request: NewCollection.SendCollection.Request)
    func update(request: NewCollection.UpdateCollection.Request)
}

final class NewCollectionInteractor {
    var presenter: NewCollectionPresentationLogic?
}

extension NewCollectionInteractor: NewCollectionBusinessLogic {
    func send(request: NewCollection.SendCollection.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.createCollection(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func update(request: NewCollection.UpdateCollection.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.updateCollection(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
