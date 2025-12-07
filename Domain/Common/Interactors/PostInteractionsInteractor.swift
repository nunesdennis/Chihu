//
//  PostInteractionsInteractor.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import Foundation

protocol PostInteractionsBusinessLogic {
    func delete(request: PostInteraction.Delete.Request)
    func likeDislike(request: PostInteraction.LikeDislike.Request)
    func repost(request: PostInteraction.Repost.Request)
}

final class PostInteractionsInteractor {
    var presenter: PostInteractionsPresentationLogic?
}

extension PostInteractionsInteractor: PostInteractionsBusinessLogic {
    func repost(request: PostInteraction.Repost.Request) {
        let worker = PostInteractionsNetworkingWorker()
        Task(priority: .background) {
            await worker.repost(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response: response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
    
    func likeDislike(request: PostInteraction.LikeDislike.Request) {
        let worker = PostInteractionsNetworkingWorker()
        Task(priority: .background) {
            await worker.likeDislikePost(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
    
    func delete(request: PostInteraction.Delete.Request) {
        let worker = PostInteractionsNetworkingWorker()
        Task(priority: .background) {
            await worker.deletePost(request: request) { [unowned self] result in
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
