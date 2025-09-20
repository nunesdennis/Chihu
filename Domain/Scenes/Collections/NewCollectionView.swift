//
//  NewCollectionView.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import SwiftUI

protocol NewCollectionDisplayLogic {
    func display(viewModel: NewCollection.SendCollection.ViewModel)
    func display(viewModel: NewCollection.UpdateCollection.ViewModel)
    func displayError(_ error: Error)
}

extension NewCollectionView: NewCollectionDisplayLogic {
    func display(viewModel: NewCollection.UpdateCollection.ViewModel) {
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
    
    func display(viewModel: NewCollection.SendCollection.ViewModel) {
        DispatchQueue.main.async {
            closeSheet()
        }
    }
    
    func createCollection() {
        let title = dataStore.titleInputText
        let description = dataStore.inputText
        
        guard   !title.isEmpty &&
                !description.isEmpty else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Title or Description are empty")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        let body = NewCollection.SendCollection.Request.CollectionRequestBody(title: title, brief: description, visibility: selectedVisibility)
        let request = NewCollection.SendCollection.Request(body: body)
        interactor.send(request: request)
    }
    
    func updateCollection(_ collection: CollectionSection) {
        let title = dataStore.titleInputText
        let description = dataStore.inputText
        
        guard   !title.isEmpty &&
                !description.isEmpty else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey("Title or Description are empty")
            dataStore.shouldShowAlert = true
            return
        }
        
        guard let interactor else {
            dataStore.alertType = .error
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.errorDescription ?? "Unknown")
            dataStore.shouldShowAlert = true
            return
        }
        
        let body = NewCollection.UpdateCollection.Request.CollectionRequestBody(title: title, brief: description, visibility: selectedVisibility)
        let request = NewCollection.UpdateCollection.Request(uuid: collection.uuid,body: body)
        interactor.update(request: request)
    }
}

protocol NewCollectionDelegate {
    func didEndCreation()
}

struct NewCollectionView: View {
    let delegate: NewCollectionDelegate
    var collection: CollectionSection?
    var interactor: NewCollectionBusinessLogic?
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var titleIsFocused: Bool
    @FocusState private var commentIsFocused: Bool
    
    @ObservedObject var dataStore = NewCollectionDataStore()
    
    @State var selectedVisibility: Int = 0
    
    let visibilityList: [Visibility] = [.public, .followersOnly, .mentionedOnly]
    
    init(delegate: NewCollectionDelegate, collection: CollectionSection? = nil) {
        self.delegate = delegate
        self.collection = collection
        
        if let collection {
            dataStore.titleInputText = collection.title
            dataStore.inputText = collection.description ?? String()
        }
    }
    
    var body: some View {
        VStack {
            navigationButtons()
            titleView()
            commentView()
            visibilityFilter()
            Spacer()
        }
        .onTapGesture {
            commentIsFocused = false
            titleIsFocused = false
        }
        .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(dataStore.alertMessage ?? "Error")
        }
        .background(Color.newCollectionViewBackgroundColor)
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
            if let collection {
                updateCollection(collection)
            } else {
                createCollection()
            }
        }) {
            if collection != nil {
                Text("Update")
            } else {
                Text("Create")
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
    
    func titleView() -> some View {
        VStack(spacing: 8) {
            TextField("Title", text: $dataStore.titleInputText, axis: .vertical)
                .focused($titleIsFocused)
                .lineLimit(1, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.newCollectionCommentBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
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
        delegate.didEndCreation()
    }
}
