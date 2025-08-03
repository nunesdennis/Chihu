//
//  ErrorView.swift
//  Chihu
//
//  Created by Dennis Nunes on 16/11/24.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    let backgroundColor: Color
    
    init(error: Error?, backgroundColor: Color = Color.errorViewBackgroundColor) {
        self.error = error ?? ChihuError.unknown
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack {
            errorImage()
                .resizable()
                .frame(width: 80, height: 80, alignment: .center)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.primary.opacity(0.25), lineWidth: 1)
                )
            Text(errorTitle())
                .font(.title2)
            Text(errorDescription())
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(width: 200, height: 120, alignment: .top)
            Spacer()
        }
        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
        .padding(24)
        .background(backgroundColor)
    }
    
    func errorImage() -> Image {
        let imageName: String
        
        if let chihuError = error as? ChihuError {
            return chihuError.errorImage
        } else {
            imageName = "error10"
        }
        
        return Image(imageName)
    }
    
    func errorTitle() -> String {
        if let chihuError = error as? ChihuError {
            return chihuError.errorTitle
        } else {
            return "¯\\_(ツ)_/¯"
        }
    }
    
    func errorDescription() -> String {
        error.localizedDescription
    }
}

#Preview {
    ErrorView(error: ChihuError.noResultsTryURL)
}
