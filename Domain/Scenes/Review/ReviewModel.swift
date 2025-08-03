//
//  ReviewModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//  
//

import Foundation

enum Review {
    enum Delete {
        struct Request: ReviewRequestProtocol {
            let method: HTTPMethod = .delete
            let itemUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum Send {
        struct Request: ReviewRequestProtocol {
            struct ReviewRequestBody: Encodable {
                let shelfType: String
                let visibility: Int
                let comment: String
                let rating: Int?
                let tags: [String]
                let crosspost: Bool
                
                enum CodingKeys: String, CodingKey {
                    case shelfType = "shelf_type"
                    case visibility
                    case comment = "comment_text"
                    case rating = "rating_grade"
                    case tags
                    case crosspost = "post_to_fediverse"
                }
            }
            
            let method: HTTPMethod = .post
            var body: Encodable?
            let itemUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum Load {
        struct Request: ReviewRequestProtocol {
            let method: HTTPMethod = .get
            let itemUUID: String
        }
        
        struct Response: Decodable {
            let shelfItem: ShelfItem
        }
        
        struct ViewModel {
            let shelfItemsViewModel: ItemViewModel
            
            init(shelfItem: ShelfItem) {
                self.shelfItemsViewModel = ItemViewModelBuilder.create(from: shelfItem)
            }
        }
    }
    
    enum Update {
        struct Request {
            let apiURL: String
            let itemClass: any ItemProtocol.Type
        }
        
        struct Response {
            let item: any ItemProtocol
        }
        
        struct ViewModel {
            let shelfItemsViewModel: ItemViewModel
            
            init(item: any ItemProtocol) {
                self.shelfItemsViewModel = ItemViewModelBuilder.create(from: item)
            }
        }
    }
    
    enum LoadSeason {
        struct Request {
            let apiURL: String
        }
        
        struct Response {
            let item: any ItemProtocol
        }
        
        struct ViewModel {
            let shelfItemsViewModel: ItemViewModel
            
            init(item: any ItemProtocol) {
                self.shelfItemsViewModel = ItemViewModelBuilder.create(from: item)
            }
        }
    }
}

enum FullReview {
    enum Delete {
        struct Request: FullReviewRequestProtocol {
            let method: HTTPMethod = .delete
            let itemUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum Send {
        struct Request: FullReviewRequestProtocol {
            struct ReviewRequestBody: Encodable {
                let visibility: Int
                let title: String
                let body: String
                let crosspost: Bool
                
                enum CodingKeys: String, CodingKey {
                    case visibility
                    case title
                    case body
                    case crosspost = "post_to_fediverse"
                }
            }
            
            let method: HTTPMethod = .post
            var body: Encodable?
            let itemUUID: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
    
    enum Load {
        struct Request: FullReviewRequestProtocol {
            let method: HTTPMethod = .get
            let itemUUID: String
        }
        
        struct Response: Decodable {
            let shelfItem: ShelfItem
        }
        
        struct ViewModel {
            let shelfItemsViewModel: ItemViewModel
            
            init(shelfItem: ShelfItem) {
                self.shelfItemsViewModel = ItemViewModelBuilder.create(from: shelfItem)
            }
        }
    }
}

extension Review.Send.Request.ReviewRequestBody {
    static func createDefaultWishlistBody() -> Review.Send.Request.ReviewRequestBody {
        .init(shelfType: "wishlist",
              visibility: UserSettings.shared.userPreference?.defaultVisibility.rawValue ?? Visibility.public.rawValue,
              comment: String(),
              rating: nil,
              tags: [],
              crosspost: false)
    }
}
