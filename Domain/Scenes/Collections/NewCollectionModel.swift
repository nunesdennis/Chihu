//
//  NewCollectionModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation

enum NewCollection {
    enum SendCollection {
        struct Request: CollectionsRequestProtocol {
            struct CollectionRequestBody: Encodable {
                let title: String
                let brief: String
                let visibility: Int
            }
            
            let method: HTTPMethod = .post
            var body: Encodable?
        }
        
        struct Response {
            let collectionModel: CollectionModel
        }
        
        struct ViewModel {
            let collectionModel: CollectionModel
        }
    }
    
    enum UpdateCollection {
        struct Request: CollectionsRequestProtocol {
            struct CollectionRequestBody: Encodable {
                let title: String
                let brief: String
                let visibility: Int
            }
            
            let method: HTTPMethod = .put
            let uuid: String
            var body: Encodable?
        }
        
        struct Response {
            let collectionModel: CollectionModel
        }
        
        struct ViewModel {
            let collectionModel: CollectionModel
        }
    }
}
