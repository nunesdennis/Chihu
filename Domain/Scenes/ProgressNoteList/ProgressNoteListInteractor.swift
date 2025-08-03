//
//  ProgressNoteListInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//  
//
import Foundation

protocol ProgressNoteListBusinessLogic {
    func load(request: ProgressNoteList.Load.Request)
    func delete(request: ProgressNoteList.Delete.Request)
}

final class ProgressNoteListInteractor {
    typealias Request = ProgressNoteList.Load.Request
    typealias Response = ProgressNoteList.Load.Response
    var presenter: ProgressNoteListPresentationLogic?
}

extension ProgressNoteListInteractor: ProgressNoteListBusinessLogic {
    func delete(request: ProgressNoteList.Delete.Request) {
        let worker = ProgressNoteListNetworkingWorker()
        worker.deleteNote(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func load(request: Request) {
        let worker = ProgressNoteListNetworkingWorker()
        worker.fetchNoteList(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
