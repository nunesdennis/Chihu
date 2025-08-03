//
//  RatingRow.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 24/06/25.
//

import SwiftUI

struct RatingRow: View {
    
    let emotionList = ["🤬","😡","😒","☹️","🙁","😐","🙂","☺️","🥰","😍","🤩"]
    var neoDBrating: Double?
    var userRating: Int?
    
    var neoDBratingString: String {
        if let neoDBrating {
            return String(format: "%.2f", neoDBrating)
        }
        
        return "--"
    }
    
    var userRatingString: String {
        if let userRating {
            return "\(userRating)"
        }
        
        return "--"
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if userRating != nil && UserSettings.shared.showYourScore {
                userRatingImage
                Text(userRatingString)
                    .fontWeight(.bold)
                    .foregroundColor(.chihuBlack)
                    .scaledToFit()
                    .minimumScaleFactor(0.1)
            }
            if userRating != nil && neoDBrating != nil && UserSettings.shared.showNeoDBscore && UserSettings.shared.showYourScore {
                Spacer()
                    .frame(width: 1)
            }
            if neoDBrating != nil && UserSettings.shared.showNeoDBscore {
                Text("🧩")
                    .font(.system(size: 14))
                    .frame(width: 20, height: 20)
                Text(neoDBratingString)
                    .fontWeight(.bold)
                    .foregroundColor(.chihuBlack)
                    .scaledToFit()
                    .minimumScaleFactor(0.1)
            }
        }
        .frame(height: 25)
    }
    
    var userRatingImage: some View {
        Group {
            if let userRating {
                Text(emotionList[userRating])
                    .font(.system(size: 14))
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "smiley")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.chihuGray).opacity(0.8)
            }
        }
    }
}

#Preview {
    RatingRow(neoDBrating: 8, userRating: 6)
}
