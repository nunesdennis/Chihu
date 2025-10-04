//
//  NewCollectionInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation

protocol ReplyBusinessLogic {
    func send(request: Reply.Send.Request)
    func update(request: Reply.Update.Request)
}

final class ReplyInteractor {
    var presenter: ReplyPresentationLogic?
}

extension ReplyInteractor: ReplyBusinessLogic {
    func send(request: Reply.Send.Request) {
        let worker = TimelineNetworkingWorker()
        Task(priority: .background) {
            await worker.reply(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
    
    func update(request: Reply.Update.Request) {
        let worker = TimelineNetworkingWorker()
        Task(priority: .background) {
            await worker.updateReply(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
}
