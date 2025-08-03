//
//  SimpleProgressNoteListView.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//

import SwiftUI

protocol ProgressNoteListDisplayLogic {
    func display(viewModel: ProgressNoteList.Delete.ViewModel)
    func display(viewModel: ProgressNoteList.Load.ViewModel)
    func displayError(_ error: Error)
}

extension SimpleProgressNoteListView: ProgressNoteListDisplayLogic {
    func display(viewModel: ProgressNoteList.Delete.ViewModel) {
        delegate.didDeleteNote()
        if dataStore.noteList.count == 1 {
            dataStore.noteList = []
        }
        fetch()
    }
    
    func display(viewModel: ProgressNoteList.Load.ViewModel) {
        DispatchQueue.main.async {
            if !viewModel.notes.isEmpty {
                dataStore.noteList = viewModel.notes
                dataStore.count += viewModel.count
                dataStore.pages = viewModel.pages
                dataStore.state = .loaded
            } else {
                dataStore.state = .loaded
            }
            delegate.didLoadNotes(dataStore.noteList)
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            if let _ = error as? ChihuError {
                dataStore.state = .error(error)
            } else {
                dataStore.state = .error(ChihuError.api(error: error))
            }
        }
    }
    
    func fetch() {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let request = ProgressNoteList.Load.Request(itemUuid: dataStore.item.uuid, page: 1)
        interactor.load(request: request)
    }
    
    func deleteNote(uuid: String) {
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let request = ProgressNoteList.Delete.Request(noteUuid: uuid)
        interactor.delete(request: request)
    }
}

protocol SimpleProgressNoteListViewDelegate {
    func didDeleteNote()
    func didTapEditNote(_ note: NoteSchema)
    func didLoadNotes(_ notes: [NoteSchema])
}

struct SimpleProgressNoteListView: View {
    var interactor: ProgressNoteListBusinessLogic?
    var delegate: SimpleProgressNoteListViewDelegate
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @ObservedObject var dataStore = ProgressNoteListDataStore()
    
    init(item: ItemViewModel, noteList: [NoteSchema], delegate: SimpleProgressNoteListViewDelegate, isLoaded: Bool) {
        self.delegate = delegate
        dataStore.item = item
        if isLoaded {
            dataStore.noteList = noteList
            dataStore.state = .loaded
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            switch dataStore.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .task {
                        fetch()
                    }
            case .loaded:
                if dataStore.noteList.isEmpty {
                    Spacer()
                } else {
                    Text("Notes")
                        .font(.title3)
                        .bold()
                        .frame(alignment: .leading)
                        .padding(EdgeInsets(top: .zero, leading: 24, bottom: .zero, trailing: .zero))
                    List(dataStore.noteList.reversed(), id: \.self) { note in
                        textCell(note)
                            .listRowBackground(Color.simpleNoteListViewRowBackgroundColor)
                            .swipeActions(edge: .leading) {
                                Button("Edit Note") {
                                    delegate.didTapEditNote(note)
                                }
                                .tint(.chihuBlue)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete Note") {
                                    deleteNote(uuid: note.uuid)
                                }
                                .tint(.chihuRed)
                            }
                    }
                    .frame(minHeight: minRowHeight * 6, maxHeight: minRowHeight * 10)
                    .listStyle(.plain)
                }
            case .error(let error):
                errorView(error)
            }
        }
    }
    
    func textCell(_ note: NoteSchema) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let type = note.progressType?.buttonName(),
                   let value = note.progressValue {
                    HStack(spacing: 8) {
                        Text(type)
                        Text(value)
                    }
                    .padding(6)
                    .background(Color.chihuGreen.opacity(0.2))
                    .cornerRadius(8)
                }
                if let title = note.title,
                   !title.isEmpty {
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.chihuRed).opacity(0.8)
                }
                if !note.content.isEmpty {
                    Text(note.content)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
        }
        .tint(Color.chihuBlack)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func errorView(_ error: Error) -> some View {
        if let apiError = error as? ChihuError {
            if case ChihuError.api(error: let error) = apiError {
                return ErrorView(error: error, backgroundColor: .chihuClear)
            } else {
                return ErrorView(error: apiError, backgroundColor: .chihuClear)
            }
        }
        return ErrorView(error: error, backgroundColor: .chihuClear)
    }
}
