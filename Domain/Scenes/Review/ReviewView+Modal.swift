//
//  ReviewView+Modal.swift
//  Chihu
//
//


import SwiftUI
import Foundation

enum ReviewViewType {
    case review(ItemViewModel)
}

struct ShowReviewAction {
    typealias Action = (ReviewViewType) -> Void
    let action: Action
    
    func callAsFunction(_ type: ReviewViewType) {
        action(type)
    }
}

extension EnvironmentValues {
    @Entry var reviewItem = ShowReviewAction(action: { _ in })
}

// to call it:
// @Environment(\.reviewItem) private var reviewItem
// reviewItem(.review(item))
