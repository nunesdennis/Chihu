//
//  ProgressNoteListModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//  
//
import Foundation

enum ProgressNoteList {
    enum Load {
        struct Request: ProgressNoteRequestProtocol {
            let method: HTTPMethod = .get
            let itemUuid: String
            let page: Int
        }
        
        struct Response {
            let noteList: NoteList
        }
        
        struct ViewModel {
            let pages: Int
            let count: Int
            let notes: [NoteSchema]
            
            init(noteList: NoteList) {
                pages = noteList.pages
                count = noteList.count
                notes = noteList.data
            }
        }
    }
    
    enum Send {
        struct Request: ProgressNoteRequestProtocol {
            struct NoteRequestBody: Encodable {
                let title: String // content warning
                let content: String
                let sensitive: Bool // content warning
                let progressType: String
                let progressValue: String
                let visibility: Int
                let postToFediverse: Bool
            }
            
            let method: HTTPMethod = .post
            var body: Encodable?
            let itemUuid: String
        }
        
        struct Response {
            let note: NoteSchema
        }
        
        struct ViewModel {
            let note: NoteSchema
        }
    }
    
    enum Update {
        struct Request: ProgressNoteRequestProtocol {
            struct NoteRequestBody: Encodable {
                let title: String // content warning
                let content: String
                let sensitive: Bool // content warning
                let progressType: String
                let progressValue: String
                let visibility: Int
                let postToFediverse: Bool
            }
            
            let method: HTTPMethod = .put
            var body: Encodable?
            let noteUuid: String
        }
        
        struct Response {
            let note: NoteSchema
        }
        
        struct ViewModel {
            let note: NoteSchema
        }
    }
    
    enum Delete {
        struct Request: ProgressNoteRequestProtocol {
            let method: HTTPMethod = .delete
            let noteUuid: String
        }
        
        struct Response {
            let message: String
        }
        
        struct ViewModel {
            let message: String
        }
    }
}
