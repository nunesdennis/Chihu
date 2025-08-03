//
//  HeaderLoginView.swift
//  Chihu
//
//  Created by Dennis Nunes on 17/11/24.
//

import SwiftUI

struct HeaderLoginView: View {
    var body: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .top) {
                HalfCircle()
                    .fill(Color.headerLoginColor)
                    .frame(width: .infinity, height: 580)
                VStack {
                    Spacer()
                    Image("loginHeaderImage")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.primary.opacity(0.25), lineWidth: 1)
                        )
                    Text("Chihu")
                        .font(.title)
                    Text("For NeoDB")
                        .font(.body)
                        .foregroundStyle(Color.chihuGray)
                }
                .frame(width: .infinity, height: 300)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HeaderLoginView()
}

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path ()
        
        path.move(to: CGPoint(x: 0, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        let height = ((rect.maxY - rect.midY)/4) + rect.midY
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.midY), control: CGPoint(x: rect.midX, y: height))
        path.closeSubpath()
        
        return path
    }
}
