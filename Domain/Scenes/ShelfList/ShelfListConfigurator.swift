//
//  ShelfListConfigurator.swift
//  Chihu
//
//  
//

import SwiftUI

extension ShelfListFilterView {
    func configureView() -> some View {
        var view = self
        let interactor = ShelfListInteractor()
        let presenter = ShelfListPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
