//
//  ReplyDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation
import SwiftUI

enum ReplyAlertType {
    case success
    case error
}

final class ReplyDataStore: ObservableObject {
    @Published var inputText: String = String()
    @Published var shouldShowAlert = false
    var alertType: ReplyAlertType?
    var alertMessage: LocalizedStringKey?
}
