//
//  ProgressNoteListConfigurator.swift
//  Chihu
//
//  
//
import SwiftUI

extension SimpleProgressNoteListView {
    func configureView() -> some View {
        var view = self
        let interactor = ProgressNoteListInteractor()
        let presenter = ProgressNoteListPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
