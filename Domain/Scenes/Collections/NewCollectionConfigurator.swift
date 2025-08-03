//
//  NewCollectionConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import SwiftUI

extension NewCollectionView {
    func configureView() -> some View {
        var view = self
        let interactor = NewCollectionInteractor()
        let presenter = NewCollectionPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
