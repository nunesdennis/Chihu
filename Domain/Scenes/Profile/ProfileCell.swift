//
//  ProfileCell.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import SwiftUI
import PhotosUI

struct ProfileCell: View {
    
    let viewModel: Profile.Load.ViewModel
    var interactor: ProfileBusinessLogic?
    @ObservedObject var dataStore: SettingsDataStore
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                CachedAsyncImage(url: viewModel.avatar) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Image("ProfileAvatar")
                            .resizable()
                    }
                }
                .clipShape(Circle())
                .frame(width: 60, height: 60)
                .overlay {
                    if dataStore.isUpdatingAvatar {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 60, height: 60)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                }
                
                // Photo picker button
                Button {
                    dataStore.isPhotoPickerPresented = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .frame(width: 25, height: 25)
                        .background(Color.chihuGreen)
                        .clipShape(Circle())
                }
                .offset(x: 5, y: 5)
                .disabled(dataStore.isUpdatingAvatar)
            }
            ProfileText(viewModel: viewModel)
        }
        .padding(5)
        .photosPicker(
            isPresented: $dataStore.isPhotoPickerPresented,
            selection: $dataStore.mediaPickers,
            maxSelectionCount: 1,
            matching: .any(of: [.images]),
            photoLibrary: .shared()
        )
        .onChange(of: dataStore.mediaPickers) { _, newValue in
            if let item = newValue.first {
                Task {
                    await handleImageSelection(item)
                }
            }
        }
    }
    
    private func handleImageSelection(_ item: PhotosPickerItem) async {
        dataStore.isUpdatingAvatar = true
        
        do {
            // Load the image data directly
            guard let data = try await item.loadTransferable(type: Data.self) else {
                showError(.processImageError)
                dataStore.isUpdatingAvatar = false
                return
            }
            
            // Compress the image
            guard let image = UIImage(data: data),
                  let compressedData = image.jpegData(compressionQuality: 0.8) else {
                showError(.processImageError)
                dataStore.isUpdatingAvatar = false
                return
            }
            
            let request = Profile.UpdateAvatar.Request(imageData: compressedData)
            interactor?.updateAvatar(request: request)
        } catch {
            showError(.processImageError)
        }
        
        dataStore.isUpdatingAvatar = false
        dataStore.mediaPickers = []
    }
    
    private func showError(_ error: ChihuError) {
        DispatchQueue.main.async {
            dataStore.errorMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.showError = true
        }
    }
    
    private func showAlert(_ message: String) {
        DispatchQueue.main.async {
            dataStore.alertMessage = LocalizedStringKey(message)
            dataStore.showAlert = true
        }
    }
}
