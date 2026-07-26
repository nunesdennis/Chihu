//
//  ShelfListInteractor.swift
//  Chihu
//
//  
//

import Foundation

protocol ShelfListBusinessLogic {
    func load(request: ShelfList.Load.Request)
    func loadAll(request: ShelfList.Load.Request)
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

    func loadAll(request: Request) {
        let worker = ShelfListNetworkingWorker()
        var allItems: [ShelfItem] = []
        
        func fetchPage(_ page: Int) {
            var pageRequest = request
            pageRequest.page = page

            worker.fetchShelf(request: pageRequest) { [weak self] result in
                switch result {
                case .success(let response):
                    let shelf = response.shelf
                    allItems.append(contentsOf: shelf.data)

                    guard !response.shelf.data.isEmpty else {
                        let loadedShelf = Shelf(
                            pages: request.page,
                            count: allItems.count,
                            data: allItems
                        )
                        self?.presenter?.present(response: Response(shelf: loadedShelf))
                        return
                    }

                    fetchPage(page + 1)

                case .failure(let error):
                    let loadedShelf = Shelf(
                        pages: request.page,
                        count: allItems.count,
                        data: allItems
                    )
                    self?.presenter?.present(response: Response(shelf: loadedShelf))
                    return
                }
            }
        }

        fetchPage(request.page)
    }
}
