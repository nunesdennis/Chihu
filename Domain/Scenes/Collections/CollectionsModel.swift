//
//  CollectionsModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//  
//
import Foundation

enum Collections {
    enum Load {
        struct Request: CollectionsRequestProtocol {
            let method: HTTPMethod = .get
            let page: Int
        }
        
        struct Response {
            let collection: CollectionList
        }
        
        struct ViewModel {
            let pages: Int
            let count: Int
            let items: [CollectionModel]
            
            init(collections: CollectionList) {
                pages = collections.pages
                count = collections.count
                items = collections.data
            }
        }
    }
    
    enum Delete {
        struct Request: CollectionsRequestProtocol {
            let method: HTTPMethod = .delete
            let uuid: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum LoadItems {
        struct Request: CollectionsItemRequestProtocol {
            let method: HTTPMethod = .get
            let collectionUUID: String
            let page: Int
        }
        
        struct Response {
            let collectionUUID: String
            let collectionItemList: CollectionItemList
        }
        
        struct ViewModel {
            let collectionUUID: String
            let pages: Int
            let count: Int
            let data: [CollectionItemData]
            
            init(collectionUUID: String, collections: CollectionItemList) {
                self.collectionUUID = collectionUUID
                pages = collections.pages
                count = collections.count
                data = collections.data
            }
        }
    }
    
    enum SendItems {
        struct Request: CollectionsItemRequestProtocol {
            struct CollectionRequestBody: Encodable {
                let itemUUID: String
                let note: String
                
                enum CodingKeys: String, CodingKey {
                    case note
                    case itemUUID = "item_uuid"
                }
            }
            
            let method: HTTPMethod = .post
            var body: Encodable?
            let collectionUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum DeleteItems {
        struct Request: CollectionsItemRequestProtocol {
            let method: HTTPMethod = .delete
            let collectionUUID: String
            let itemUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
}
