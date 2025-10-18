//
//  PostInteractionsDisplayLogic.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

protocol PostInteractionsDisplayLogic {
    func display(viewModel: PostInteraction.LikeDislike.ViewModel) async
    func displayToastError(_ error: any Error)
}
