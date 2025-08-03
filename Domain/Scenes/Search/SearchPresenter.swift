//
//  SearchPresenter.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import Foundation

protocol SearchPresentationLogic {
    func presentResultFromPIname(response: SearchByNamePI.Load.Response)
    func presentResultFromGoogleBooksName(response: SearchByNameGoogleBooks.Load.Response, category: String)
    func presentResultFromTMDBname(response: SearchByNameTMDB.Load.Response, category: String)
    func presentResultFromName(response: SearchByName.Load.Response)
    func presentResultFromURL(response: SearchByURL.Load.Response)
    func presentResultFromURLAndOpen(response: SearchByURL.Load.Response)
    func present(error: Error)
}

final class SearchPresenter {
    var view: SearchDisplayLogic?
}

extension SearchPresenter: SearchPresentationLogic {
    func presentResultFromGoogleBooksName(response: SearchByNameGoogleBooks.Load.Response, category: String) {
        let viewModel = SearchByNameGoogleBooks.Load.ViewModel(shelf: response.shelf, category: category)
        view?.displayResultFromGoogleBooksName(viewModel: viewModel)
    }
    
    func presentResultFromTMDBname(response: SearchByNameTMDB.Load.Response, category: String) {
        let viewModel = SearchByNameTMDB.Load.ViewModel(shelf: response.shelf, category: category)
        view?.displayResultFromTMDBname(viewModel: viewModel)
    }
    
    func presentResultFromPIname(response: SearchByNamePI.Load.Response) {
        let viewModel = SearchByNamePI.Load.ViewModel(shelf: response.shelf)
        view?.displayResultFromPIname(viewModel: viewModel)
    }
    
    func presentResultFromName(response: SearchByName.Load.Response) {
        let viewModel = SearchByName.Load.ViewModel(catalog: response.catalog)
        view?.displayResultFromName(viewModel: viewModel)
    }
    
    func presentResultFromURL(response: SearchByURL.Load.Response) {
        let viewModel = SearchByURL.Load.ViewModel(shelfItemDetails: response.shelfItemDetails)
        view?.displayResultFromURL(viewModel: viewModel)
    }
    
    func presentResultFromURLAndOpen(response: SearchByURL.Load.Response) {
        let viewModel = SearchByURL.Load.ViewModel(shelfItemDetails: response.shelfItemDetails)
        view?.openResultFromURL(viewModel: viewModel)
    }
    
    func present(error: Error) {
        view?.displayError(error)
    }
}
