//
//  TipView.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/12/24.
//

import SwiftUI
import MarkdownUI

struct TipView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var text: String {
        let tip =
        """
        ## Tip:
        #### Paste the link of one of the compatible sites into the search field:
        Douban, Goodreads, Google Books, BooksTW, IMDb, TMDB, Bandcamp, Spotify, IGDB, Steam, Bangumi, BGG, RSS, Discogs, Apple Music, Fediverse, Qidian, Ypshuo.
        """
        
        return tip.localized
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.searchViewColor)
                VStack {
                    Markdown(text)
                        .markdownTextStyle(\.text) {
                            ForegroundColor(.chihuBlack)
                            BackgroundColor(.chihuClear)
                        }
                        .markdownTheme(.gitHub)
                        .padding(20)
                }
                .frame(width: geometry.size.width - 40, height: 300)
                .background(Color.chihuWhite)
                .cornerRadius(25)
                .padding()
                VStack {
                    Image("tip1")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .top)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.8), lineWidth: 5)
                        )
                    Spacer()
                }
                .frame(width: geometry.size.width - 40, height: imageHeight(), alignment: .top)
                VStack {
                    HStack {
                        Spacer()
                        closeButton()
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width - 40, height: 300)
                .padding()
            }
        }
    }
    
    func imageHeight() -> CGFloat {
        let height = UIScreen.main.bounds.height
        if height == 667 {
            return 320
        } else {
            return 390
        }
    }
    
    func closeButton() -> some View {
        Button(action: {
            UserSettings.shared.shouldHideTip = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .font(Font.body.weight(.bold))
                    .scaleEffect(0.416)
                    .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
                    .frame(width: 30, height: 30)
            }
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    TipView()
}
