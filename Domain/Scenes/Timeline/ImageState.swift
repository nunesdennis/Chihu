//
//  ImageState.swift
//  Chihu
//
//

import Foundation
import SwiftUI

enum ImageState {
    case placeHolder
    case loaded(Image)
    case needsLoading
    case none
}

extension ImageState: Equatable {
    static func == (lhs: ImageState, rhs: ImageState) -> Bool {
        switch (lhs, rhs) {
        case (.placeHolder, .placeHolder),
             (.loaded, .loaded),
             (.none, .none),
            (.needsLoading, .needsLoading):
            return true
        default:
            return false
        }
    }
}

enum ImageType {
    case avatar
    case poster
}
