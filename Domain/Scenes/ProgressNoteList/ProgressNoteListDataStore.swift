//
//  ProgressNoteListDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//  
//
import Foundation

enum ProgressNoteListState {
    case loading
    case loaded
    case error(Error)
}

final class ProgressNoteListDataStore: ObservableObject {
    @Published var state: ProgressNoteListState = .loading
    @Published var item: ItemViewModel!
    @Published var noteList: [NoteSchema] = []
    var pages: Int = 0
    var count: Int = 0
}
