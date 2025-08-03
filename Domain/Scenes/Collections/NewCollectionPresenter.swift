//
//  NewCollectionPresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation

protocol NewCollectionPresentationLogic {
    func present(response: NewCollection.UpdateCollection.Response)
    func present(response: NewCollection.SendCollection.Response)
    func present(error: Error)
}

final class NewCollectionPresenter {
    typealias Response = NewCollection.SendCollection.Response
    typealias ViewModel = NewCollection.SendCollection.ViewModel
    var view: NewCollectionDisplayLogic?
}

extension NewCollectionPresenter: NewCollectionPresentationLogic {
    func present(response: NewCollection.UpdateCollection.Response) {
        let viewModel = NewCollection.UpdateCollection.ViewModel(collectionModel: response.collectionModel)
        view?.display(viewModel: viewModel)
    }
    
    func present(response: Response) {
        let viewModel = NewCollection.SendCollection.ViewModel(collectionModel: response.collectionModel)
        view?.display(viewModel: viewModel)
    }
    
    func present(error: any Error) {
        view?.displayError(error)
    }
}
