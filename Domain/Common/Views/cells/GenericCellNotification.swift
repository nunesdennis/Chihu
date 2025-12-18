//
//  GenericCellNotificationCell.swift
//  Chihu
//

import SwiftUI
import UIKit
import TootSDK
import HTML2Markdown
import MarkdownUI
import Translation

protocol GenericCellNotificationDelegate {}

@MainActor
struct GenericCellNotification: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let notification: TootNotification
    private let delegate: GenericCellNotificationDelegate
    
    // MARK: - Init
    init(notification: TootNotification,
         delegate: GenericCellNotificationDelegate) {
        self.delegate = delegate
        self.notification = notification
    }
    
    // MARK: - Body
    var body: some View {
        Text("Unsupported notification type: \(notification.type.rawValue)")
            .font(.body)
            .foregroundColor(.chihuBlack)
            .listRowBackground(Color.timelineCellBackgroundColor)
    }
}

