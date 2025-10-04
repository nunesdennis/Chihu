//
//  ReplyView.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//

import SwiftUI
import TootSDK

protocol ReplyDisplayLogic {
    func display(viewModel: Reply.Send.ViewModel)
    func display(viewModel: Reply.Update.ViewModel)
    func displayError(_ error: Error)
}

extension ReplyView: ReplyDisplayLogic {
    func display(viewModel: Reply.Update.ViewModel) {
        DispatchQueue.main.async {
            closeSheet()
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowAlert = true
        }
    }
    
    func display(viewModel: Reply.Send.ViewModel) {
        DispatchQueue.main.async {
            closeSheet()
        }
    }
    
    func sendReply() {
        let comment = dataStore.inputText
        
        guard let post else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard !comment.isEmpty else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Comment is empty")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        let visibility = visibilityList[selectedVisibility].TootSDKVisibility()
        let language = UserSettings.shared.language.rawValue
        let body = Reply.Send.Request.ReplyRequestBody(
            postId: post.id,
            comment: comment,
            visibility: visibility,
            language: language)
        let request = Reply.Send.Request(body: body)
        interactor.send(request: request)
    }
    
    func updateReply() {
        let comment = dataStore.inputText
        
        guard   let reply else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard !comment.isEmpty else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Comment is empty")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        let visibility = visibilityList[selectedVisibility].TootSDKVisibility()
        let language = UserSettings.shared.language.rawValue
        let body = Reply.Update.Request.ReplyRequestBody(
            replyPostId: reply.id,
            comment: comment)
        let request = Reply.Update.Request(body: body)
        interactor.update(request: request)
    }
}

protocol ReplyDelegate {
    func didEndReply()
}

struct ReplyView: View {
    let delegate: ReplyDelegate
    
    var post: PostProtocol?
    var reply: PostProtocol?
    
    var interactor: ReplyBusinessLogic?
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var commentIsFocused: Bool
    
    @ObservedObject var dataStore = ReplyDataStore()
    
    @State var selectedVisibility: Int = 0
    
    let visibilityList: [Visibility] = [.public, .followersOnly, .mentionedOnly]
    
    init(delegate: ReplyDelegate, post: PostProtocol? = nil, reply: PostProtocol? = nil) {
        self.delegate = delegate
        self.post = post
        self.reply = reply
        if let content = reply?.content,
           let text = TootHTML.extractAsPlainText(html: content) {
            dataStore.inputText = text
        }
    }
    
    var body: some View {
        VStack {
            navigationButtons()
            commentView()
            visibilityFilter()
            Spacer()
        }
        .onTapGesture {
            commentIsFocused = false
        }
        .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(dataStore.alertMessage ?? "Error")
        }
        .background(Color.replyViewBackgroundColor)
    }
    
    func navigationButtons() -> some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    closeButton()
                }
                .frame(width: 30, height: 30)
                Spacer()
                if #available(iOS 26, *) {
                    actionButton()
                        .buttonStyle(.glass)
                } else {
                    actionButton()
                }
            }
        }
        .padding(20)
    }
    
    func actionButton() -> some View {
        Button(action: {
            if reply != nil {
                updateReply()
            } else {
                sendReply()
            }
        }) {
            if reply != nil {
                Text("Update")
            } else {
                Text("Reply")
            }
        }
        .tint(.chihuGreen)
        .frame(height: 30)
    }
    
    func closeButton() -> some View {
        ZStack {
            Circle()
                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .font(Font.body.weight(.bold))
                .scaleEffect(0.416)
                .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
        }
    }
    
    func commentView() -> some View {
        VStack {
            TextField("Write a brief description here", text: $dataStore.inputText, axis: .vertical)
                .focused($commentIsFocused)
                .lineLimit(4, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.newCollectionCommentBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    func visibilityFilter() -> some View {
        VStack(alignment: .leading) {
            Text("Visibility")
                .font(.title3)
                .bold()
                .frame(alignment: .leading)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(visibilityList.indices, id: \.self) { index in
                    Button(visibilityList[index].visibilityButtonName()) {
                        selectedVisibility = index
                    }
                    .chihuButtonStyle()
                    .tint(buttonVisibilityColor(index: index))
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    func buttonVisibilityColor(index: Int) -> Color {
        index == selectedVisibility ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func closeSheet() {
        delegate.didEndReply()
    }
}
