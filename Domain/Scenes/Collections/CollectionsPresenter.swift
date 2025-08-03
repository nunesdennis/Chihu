//
//  CollectionsPresenter.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//  
//
import Foundation

protocol CollectionsPresentationLogic {
    func present(response: Collections.Load.Response)
    func presentMessage(message: String)
    func presentItems(response: Collections.LoadItems.Response)
    func present(error: Error)
    func presentErrorAlert(error: Error)
}

final class CollectionsPresenter {
    typealias Response = Collections.Load.Response
    typealias ViewModel = Collections.Load.ViewModel
    var view: CollectionsDisplayLogic?
}

extension CollectionsPresenter: CollectionsPresentationLogic {
    func presentErrorAlert(error: any Error) {
        view?.displayErrorMessage(error)
    }
    
    func presentMessage(message: String) {
        view?.displayMessage(message)
    }
    
    func presentItems(response: Collections.LoadItems.Response) {
        let viewModel = Collections.LoadItems.ViewModel(collectionUUID: response.collectionUUID,collections: response.collectionItemList)
        view?.displayItems(viewModel: viewModel)
    }
    
    func present(response: Response) {
        let viewModel = Collections.Load.ViewModel(collections: response.collection)
        view?.display(viewModel: viewModel)
    }
    
    func present(error: any Error) {
        view?.displayError(error)
    }
}
