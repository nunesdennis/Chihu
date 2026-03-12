//
//  CardView.swift
//  Chihu
//
//

import SwiftUI

struct CardView: View {
    let title: String
    let poster: URL?
    let lineLimit: Int?
    var neoDBrating: Double?
    var userRating: Int?
    
    var body: some View {
        VStack {
            CachedAsyncImage(poster,
                             placeHolderImage: Image("ImagePlaceHolder"))
                .aspectRatio(contentMode: .fit)
                .frame(width: .infinity)
            .cornerRadius(8)
            .layoutPriority(1)
            VStack {
                if (userRating != nil || neoDBrating != nil) && (UserSettings.shared.showNeoDBscore || UserSettings.shared.showYourScore) {
                    RatingRow(neoDBrating: neoDBrating, userRating: userRating)
                }
                Text(title)
                    .font(.body)
                    .foregroundColor(.cardViewColor)
                    .lineLimit(nil)
            }
            .padding(EdgeInsets(top: 4, leading: .zero, bottom: 4, trailing: .zero))
            Spacer()
        }
        .frame(minHeight: 200, maxHeight: 300)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: "Hello world", poster: nil, lineLimit: 2)
    }
}
