//
//  ShelfListPresenter.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
//  
//

import Foundation

protocol ShelfListPresentationLogic {
    func present(response: ShelfList.Load.Response)
    func present(error: Error)
}

final class ShelfListPresenter {
    typealias Response = ShelfList.Load.Response
    typealias ViewModel = ShelfList.Load.ViewModel
    var view: ShelfListDisplayLogic?
}

extension ShelfListPresenter: ShelfListPresentationLogic {
    func present(error: Error) {
        view?.displayError(error)
    }
    
    func present(response: Response) {
        let viewModel = ShelfList.Load.ViewModel(shelf: response.shelf)
        view?.display(viewModel: viewModel)
    }
}
