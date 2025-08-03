//
//  SearchConfigurator.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import SwiftUI

extension SearchView {
    func configureView() -> some View {
        var view = self
        let interactor = SearchInteractor()
        let presenter = SearchPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
