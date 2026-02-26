//
//  ReplyDataStore.swift
//  Chihu
//
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
