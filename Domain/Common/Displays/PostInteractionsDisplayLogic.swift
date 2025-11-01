//
//  PostInteractionsDisplayLogic.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import TootSDK

protocol PostInteractionsDisplayLogic {
    func display(post: Post) async
    func displayToastError(_ error: any Error)
}
