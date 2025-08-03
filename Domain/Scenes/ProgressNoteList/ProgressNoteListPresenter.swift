//
//  ProgressNoteListPresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//  
//
import Foundation

protocol ProgressNoteListPresentationLogic {
    func present(response: ProgressNoteList.Load.Response)
    func present(response: ProgressNoteList.Delete.Response)
    func present(error: Error)
}

final class ProgressNoteListPresenter {
    typealias Response = ProgressNoteList.Load.Response
    typealias ViewModel = ProgressNoteList.Load.ViewModel
    var view: ProgressNoteListDisplayLogic?
}

extension ProgressNoteListPresenter: ProgressNoteListPresentationLogic {
    func present(response: ProgressNoteList.Delete.Response) {
        let viewModel = ProgressNoteList.Delete.ViewModel(message: response.message)
        view?.display(viewModel: viewModel)
    }
    
    func present(response: Response) {
        let viewModel = ProgressNoteList.Load.ViewModel(noteList: response.noteList)
        view?.display(viewModel: viewModel)
    }
    
    func present(error: any Error) {
        view?.displayError(error)
    }
}
