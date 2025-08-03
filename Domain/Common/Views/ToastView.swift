//
//  ToastView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 23/05/25.
//

import SwiftUI
import Foundation

enum ToastType {
    case success(LocalizedStringKey?, LocalizedStringKey)
    case failure(LocalizedStringKey?, LocalizedStringKey)
    case info(LocalizedStringKey?, LocalizedStringKey)
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.chihuGreen.opacity(0.9)
        case .failure:
            return Color.chihuRed.opacity(0.9)
        case .info:
            return Color.chihuBlue.opacity(0.9)
        }
    }
    
    var icon: Image {
        switch self {
        case .success:
            return Image(systemName: "checkmark.circle")
        case .failure:
            return Image(systemName: "xmark.octagon")
        case .info:
            return Image(systemName: "info.circle")
        }
    }
    
    var title: LocalizedStringKey? {
        switch self {
        case .success(let title, _), .failure(let title, _), .info(let title, _):
            return title
        }
    }
    
    var message: LocalizedStringKey {
        switch self {
        case .success(_ , let message), .failure(_ , let message), .info(_ , let message):
            return message
        }
    }
}

struct ToastView: View {
    
    let type: ToastType
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            type.icon
                .foregroundStyle(.white)
            VStack(alignment: .leading) {
                if let title = type.title {
                    Text(title)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                Text(type.message)
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(type.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal, 16)
    }
}

struct ShowToastAction {
    typealias Action = (ToastType) -> Void
    let action: Action
    
    func callAsFunction(_ type: ToastType) {
        action(type)
    }
}

extension EnvironmentValues {
    @Entry var showToast = ShowToastAction(action: { _ in })
}

struct ToastModifier: ViewModifier {
    
    @State private var type: ToastType?
    @State private var dismissTask: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .environment(\.showToast, ShowToastAction(action: { type in
                withAnimation(.easeInOut) {
                    self.type = type
                }
                
                // cancel previous dismissal task if any
                dismissTask?.cancel()
                
                // schedule a new dismisal
                let task = DispatchWorkItem {
                    withAnimation(.easeInOut) {
                        self.type = nil
                    }
                }
                
                self.dismissTask = task
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
            }))
            .overlay(alignment: .top) {
                if let type {
                    ToastView(type: type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(50)
                }
            }
    }
}

extension View {
    func withToast() -> some View {
        modifier(ToastModifier())
    }
}

// to call it:
// view.withToast()
// @Environment(\.showToast) private var showToast
// showToast(.success("title", "message"))
