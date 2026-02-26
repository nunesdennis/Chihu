//
//  SearchUrlConfigurator.swift
//  Chihu
//
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
