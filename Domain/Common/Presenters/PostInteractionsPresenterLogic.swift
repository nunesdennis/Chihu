//
//  PostInteractionsPresenterLogic.swift
//  Chihu
//
//

import Foundation

protocol PostInteractionsPresentationLogic {
    func present(response: PostInteraction.Delete.Response)
    func present(response: PostInteraction.Repost.Response)
    func present(response: PostInteraction.LikeDislike.Response)
    func present(error: Error)
}
