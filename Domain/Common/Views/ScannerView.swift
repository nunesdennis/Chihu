//
//  ScannerView.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/11/24.
//

import SwiftUI
import VisionKit

struct ScannerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var shouldStartScanning: Bool
    @Binding var scannedText: String
    
    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable(
                    shouldStartScanning: $shouldStartScanning,
                    scannedText: $scannedText,
                    dataToScanFor: [.barcode(symbologies: [])]
                )
            } else if !DataScannerViewController.isSupported {
                Text("It looks like this device doesn't support scanner")
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                    .padding(10)
            } else {
                Text("It appears your camera may not be available")
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                    .padding(10)
            }
            VStack {
                navigationButtons()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.scannerViewColor)
        .onChange(of: scannedText) {
            dismiss()
        }
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
    
    func navigationButtons() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                closeButton()
                    .frame(width: 30, height: 30)
            }
            .frame(width: 80, height: 80)
            Spacer()
        }
        .padding(EdgeInsets(top: 30, leading: 15, bottom: .zero, trailing: 20))
    }
}

//#Preview {
//    ScannerView(shouldStartScanning: <#Binding<Bool>#>, scannedText: <#Binding<String>#>)
//}
