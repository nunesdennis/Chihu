//
//  ShelfListInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
//  
//

import Foundation

protocol ShelfListBusinessLogic {
    func load(request: ShelfList.Load.Request)
}

final class ShelfListInteractor {
    typealias Request = ShelfList.Load.Request
    typealias Response = ShelfList.Load.Response
    var presenter: ShelfListPresentationLogic?
}

extension ShelfListInteractor: ShelfListBusinessLogic {
    func load(request: Request) {
        let worker = ShelfListNetworkingWorker()
        worker.fetchShelf(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
