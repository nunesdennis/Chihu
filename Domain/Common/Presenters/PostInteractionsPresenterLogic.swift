//
//  PostInteractionsPresenterLogic.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import Foundation

protocol PostInteractionsPresentationLogic {
    func present(response: PostInteraction.LikeDislike.Response)
    func present(error: Error)
}
