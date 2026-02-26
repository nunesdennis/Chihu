//
//  PostInteractionsDisplayLogic.swift
//  Chihu
//
//

import TootSDK

protocol PostInteractionsDisplayLogic {
    func displayError(_ error: Error)
    func display(post: Post) async
    func displayToastError(_ error: any Error)
    func remove(post: Post) async
}
