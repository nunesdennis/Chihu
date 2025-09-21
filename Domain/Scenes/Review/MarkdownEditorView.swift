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
    @Binding var showPreview: Bool
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    init(_ text: Binding<String>, showPreview: Binding<Bool>) {
        _text = text
        _showPreview = showPreview
    }
    
    var body: some View {
        ScrollView {
            if showPreview {
                Markdown(text)
                    .markdownTextStyle(\.text) {
                        ForegroundColor(.chihuBlack)
                        BackgroundColor(.chihuClear)
                    }
                    .markdownTheme(.gitHub)
                    .frame(minHeight: 600,alignment: .topLeading)
                    .padding(14)
                    .background(Color.markdownEditorBackgroundColor)
                    .allowsHitTesting(false)
            } else {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 600, alignment: .topLeading)
                    .padding(14)
                    .background(Color.markdownEditorEditorBackgroundColor)
            }
        }
    }
}

//#Preview {
//    MarkdownEditorView()
//}
