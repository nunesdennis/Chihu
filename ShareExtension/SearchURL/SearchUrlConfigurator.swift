//
//  SearchUrlConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/12/24.
//  
//
import SwiftUI

extension SearchUrlView {
    func configureView() -> some View {
        var view = self
        let interactor = SearchInteractor()
        let presenter = SearchPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
