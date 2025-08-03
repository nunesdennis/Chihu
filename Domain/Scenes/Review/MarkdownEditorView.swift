//
//  MarkdownEditorView.swift
//  Chihu
//
//  Created by Dennis Nunes on 22/12/24.
//

import SwiftUI
import MarkdownUI

struct MarkdownEditorView: View {
    
    @Binding var text: String
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var textEditorHeight: CGFloat {
        if isIpad {
            200
        } else {
            100
        }
    }
    
    init(_ text: Binding<String>) {
        _text = text
    }
    
    var body: some View {
        ScrollView {
            Markdown(text)
                .markdownTextStyle(\.text) {
                    ForegroundColor(.chihuBlack)
                    BackgroundColor(.chihuClear)
                }
                .markdownTheme(.gitHub)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .background(Color.markdownEditorBackgroundColor)
        }
        Divider()
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .frame(height: textEditorHeight)
            .padding(.bottom)
            .background(Color.markdownEditorEditorBackgroundColor)
            .layoutPriority(1)
    }
}

//#Preview {
//    MarkdownEditorView()
//}
