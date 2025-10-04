//
//  TimelineNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 13/11/24.
//

import Foundation
import TootSDK

protocol TimelineNetworkingProtocol {
    func fetchPosts(request: Timeline.Load.Request,completion: @escaping (Result<Timeline.Load.Response, Error>) -> Void) async
}

final class TimelineNetworkingWorker: TimelineNetworkingProtocol {
    
    // MARK: - Public Methods
    func fetchPosts(request: Timeline.Load.Request, completion: @escaping (Result<Timeline.Load.Response, Error>) -> Void) async {
        let endpoint = TimelineEndpoint(request)
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
            let items = try await client.getTimeline(request.timelineType, pageInfo: request.pageInfo)
            let response = Timeline.Load.Response(posts: items.result)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func reply(request: Reply.Send.Request, completion: @escaping (Result<Reply.Send.Response, Error>) -> Void) async {
        let endpoint = ReplyEndpoint(request)
        
        guard let body = request.body as? Reply.Send.Request.ReplyRequestBody else {
            completion(.failure(ChihuError.codeError))
            return
        }
        
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
            let newPost = PostParams(post: body.comment,
                                     inReplyToId: body.postId,
                                     visibility: body.visibility,
                                     language: body.language)
            let replyPost = try await client.publishPost(newPost)
            let response = Reply.Send.Response(replyModel: replyPost)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func updateReply(request: Reply.Update.Request, completion: @escaping (Result<Reply.Update.Response, Error>) -> Void) async {
        let endpoint = ReplyEndpoint(request)
        
        guard let body = request.body as? Reply.Update.Request.ReplyRequestBody else {
            completion(.failure(ChihuError.codeError))
            return
        }
        
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
            let editPost = EditPostParams(post: body.comment)
            let replyPost = try await client.editPost(id: body.replyPostId, editPost)
            let response = Reply.Update.Response(replyModel: replyPost)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
}
