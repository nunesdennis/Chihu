//
//  PostInteractionNetworkingWorker.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import Foundation
import TootSDK

protocol PostInteractionsNetworkingProtocol {
    func likeDislikePost(request: PostInteraction.LikeDislike.Request,completion: @escaping (Result<PostInteraction.LikeDislike.Response, Error>) -> Void) async
}

final class PostInteractionsNetworkingWorker: PostInteractionsNetworkingProtocol {
    
    // MARK: - Public Methods
    func likeDislikePost(request: PostInteraction.LikeDislike.Request,completion: @escaping (Result<PostInteraction.LikeDislike.Response, Error>) -> Void) async {
        let endpoint = PostInteractionEndpoint(request)
        
        guard let url = endpoint.url else {
            completion(.failure(ChihuError.invalidURL))
            return
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            completion(.failure(ChihuError.accessTokenMissing))
            return
        }
        
        do {
            let client = try await TootClient(connect: url, accessToken: accessToken)
            let newPost: Post
            if request.favourited {
                newPost = try await client.unfavouritePost(id: request.postId)
            } else {
                newPost = try await client.favouritePost(id: request.postId)
            }
            let response = PostInteraction.LikeDislike.Response(post: newPost)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func repost(request: PostInteraction.Repost.Request,completion: @escaping (Result<PostInteraction.Repost.Response, Error>) -> Void) async {
        let endpoint = PostInteractionEndpoint(request)
        
        guard let url = endpoint.url else {
            completion(.failure(ChihuError.invalidURL))
            return
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            completion(.failure(ChihuError.accessTokenMissing))
            return
        }
        
        do {
            let client = try await TootClient(connect: url, accessToken: accessToken)
            let newPost: Post
            if request.reposted {
                newPost = try await client.unboostPost(id: request.postId)
            } else {
                newPost = try await client.boostPost(id: request.postId)
            }
            let response = PostInteraction.Repost.Response(post: newPost)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
}
