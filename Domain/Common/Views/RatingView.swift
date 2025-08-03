//
//  RatingView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/10/24.
//

import Foundation
import SwiftUI

struct EmoticonView: View {
    let emotionList = ["🤬","😡","😒","☹️","🙁","😐","🙂","☺️","🥰","😍","🤩"]
    @Binding var rating: Double?
    
    init(_ rating: Binding<Double?>) {
        _rating = rating
    }
    
    var body: some View {
        if let rating {
            Text(emotionList[Int(rating*2)])
                .font(.system(size: 50))
                .frame(width: 50, height: 50)
        } else {
            Image(systemName: "smiley")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.chihuGray).opacity(0.8)
        }
    }
}

struct RatingView: View {
    init(_ rating: Binding<Double?>, maxRating: Int = 5) {
        _ratingBinded = rating
        self.maxRating = maxRating
    }

    var rating: Double {
        ratingBinded ?? .zero
    }
    let maxRating: Int
    @Binding var ratingBinded: Double?
    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging: Bool = false

    var body: some View {
        ZStack {
            HStack {
                ForEach(0..<Int(rating), id: \.self) { idx in
                    fullStar
                }

                if (rating != floor(rating)) {
                    halfStar
                }

                ForEach(0..<Int(Double(maxRating) - rating), id: \.self) { idx in
                    emptyStar
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.chihuClear.preference(key: ControlSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(StarSizeKey.self) { size in
                starSize = size
            }
            .onPreferenceChange(ControlSizeKey.self) { size in
                controlSize = size
            }

            Color.chihuClear
                .frame(width: controlSize.width, height: controlSize.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            ratingBinded = rating(at: value.location)
                        }
                )
        }
    }

    private var fullStar: some View {
        Image(systemName: "star.fill")
            .star(size: starSize)
    }

    private var halfStar: some View {
        Image(systemName: "star.leadinghalf.fill")
            .star(size: starSize)
    }

    private var emptyStar: some View {
        Group {
            if ratingBinded != nil {
                Image(systemName: "star")
                    .star(size: starSize)
            } else {
                Image(systemName: "star")
                    .star(size: starSize)
                    .foregroundColor(.chihuGray).opacity(0.8)
            }
        }
    }

    private func rating(at position: CGPoint) -> Double {
        let singleStarWidth = starSize.width
        let totalPaddingWidth = controlSize.width - CGFloat(maxRating)*singleStarWidth
        let singlePaddingWidth = totalPaddingWidth / (CGFloat(maxRating) - 1)
        let starWithSpaceWidth = Double(singleStarWidth + singlePaddingWidth)
        let x = Double(position.x)

        let starIdx = Int(x / starWithSpaceWidth)
        let starPercent = x.truncatingRemainder(dividingBy: starWithSpaceWidth) / Double(singleStarWidth) * 100

        let rating: Double
        if starPercent < 25 {
            rating = Double(starIdx)
        } else if starPercent <= 75 {
            rating = Double(starIdx) + 0.5
        } else {
            rating = Double(starIdx) + 1
        }

        return min(Double(maxRating), max(0, rating))
    }
}

fileprivate extension Image {
    func star(size: CGSize) -> some View {
        return self
            .font(.title)
            .background(
                GeometryReader { proxy in
                    Color.chihuClear.preference(key: StarSizeKey.self, value: proxy.size)
                }
            )
            .frame(width: size.width, height: size.height)
    }
}

fileprivate protocol SizeKey: PreferenceKey { }
fileprivate extension SizeKey {
    static var defaultValue: CGSize { .zero }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        value = CGSize(width: max(value.width, next.width), height: max(value.height, next.height))
    }
}

fileprivate struct StarSizeKey: SizeKey { }
fileprivate struct ControlSizeKey: SizeKey { }
