//
//  NewCollectionDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation
import SwiftUI

enum CollectionAlertType {
    case success
    case error
}

final class NewCollectionDataStore: ObservableObject {
    @Published var titleInputText: String = String()
    @Published var inputText: String = String()
    @Published var shouldShowAlert = false
    var alertType: CollectionAlertType?
    var alertMessage: LocalizedStringKey?
}
