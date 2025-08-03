//
//  ProgressNoteListNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//

import Foundation

protocol ProgressNoteListNetworkingWorkerProtocol {
    func fetchNoteList(request: ProgressNoteList.Load.Request, completion: @escaping (Result<ProgressNoteList.Load.Response, Error>) -> Void)
    func sendNoteToItem(request: ProgressNoteList.Send.Request, completion: @escaping (Result<ProgressNoteList.Send.Response, Error>) -> Void)
    func deleteNote(request: ProgressNoteList.Delete.Request, completion: @escaping (Result<ProgressNoteList.Delete.Response, Error>) -> Void)
}

final class ProgressNoteListNetworkingWorker: ProgressNoteListNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func fetchNoteList(request: ProgressNoteList.Load.Request, completion: @escaping (Result<ProgressNoteList.Load.Response, Error>) -> Void) {
        let endpoint = ProgressNoteListEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let noteListResponse = try decoder.decode(NoteList.self, from: data)
                    completion(.success(ProgressNoteList.Load.Response.init(noteList: noteListResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateNote(request: ProgressNoteList.Update.Request, completion: @escaping (Result<ProgressNoteList.Update.Response, Error>) -> Void) {
        let endpoint = ProgressNoteListEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let note = try decoder.decode(NoteSchema.self, from: data)
                    completion(.success(ProgressNoteList.Update.Response(note: note)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendNoteToItem(request: ProgressNoteList.Send.Request, completion: @escaping (Result<ProgressNoteList.Send.Response, Error>) -> Void) {
        let endpoint = ProgressNoteListEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    print(String(decoding: data, as: UTF8.self))
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let note = try decoder.decode(NoteSchema.self, from: data)
                    completion(.success(ProgressNoteList.Send.Response(note: note)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteNote(request: ProgressNoteList.Delete.Request, completion: @escaping (Result<ProgressNoteList.Delete.Response, Error>) -> Void) {
        let endpoint = ProgressNoteListEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(ProgressNoteList.Delete.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
