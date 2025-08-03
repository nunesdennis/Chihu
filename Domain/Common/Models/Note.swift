//
//  Note.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//

import Foundation

struct NoteList: Decodable {
    let pages: Int
    let count: Int
    let data: [NoteSchema]
}

struct NoteSchema: Decodable, Identifiable, Hashable {
    var id: String {
        uuid
    }
    
    let uuid: String
    let postId: Int?
    let item: ItemSchema
    let title: String? // contentWarning/Spoiler
    let content: String
    let sensitive: Bool
    let progressType: ItemCategory.progressNoteType?
    let progressValue: String?
    let visibility: Int
    let createdTime: String
}

extension [NoteSchema] {
    static func !=(lhs: [NoteSchema], rhs: [NoteSchema]) -> Bool {
        if lhs.count != rhs.count {
            return true
        }
        
        for index in 0..<lhs.count {
            if lhs[index] != rhs[index] {
                return true
            }
        }
        
        return false
    }
}
