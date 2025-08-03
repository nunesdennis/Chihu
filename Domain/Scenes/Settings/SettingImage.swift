//
//  SettingImage.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/09/24.
//

import SwiftUI

struct SettingImage: View {
    let color: Color
    let imageName: String

    var body: some View {
        Image(systemName: imageName)
         .resizable()
         .foregroundStyle(color)
         .frame(width: 25, height: 25)
         .background(Color.chihuClear)
    }
}
