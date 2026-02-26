//
//  CollectionsConfigurator.swift
//  Chihu
//
//  
//
import SwiftUI

extension SimpleCollectionListView {
    func configureView() -> some View {
        var view = self
        let interactor = CollectionsInteractor()
        let presenter = CollectionsPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}

extension CollectionsView {
    func configureView() -> some View {
        var view = self
        let interactor = CollectionsInteractor()
        let presenter = CollectionsPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
