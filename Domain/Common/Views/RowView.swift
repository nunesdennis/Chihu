//
//  RowView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//

import SwiftUI

protocol RowViewDelegate {
    func didTapCard(_ card: Card)
    func resetList()
}

struct RowView: View {
    let delegate: RowViewDelegate
    let cards: [Card]
    let width: CGFloat
    let horizontalSpacing: CGFloat
    
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            ForEach(cards) { card in
                Button {
                    delegate.didTapCard(card)
                } label: {
                    CardView(title: card.title, poster: card.poster, lineLimit: 2, neoDBrating: card.neoDBrating, userRating: card.userRating)
                        .frame(width: width)
                }
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 8, bottom: .zero, trailing: 8))
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [Card] = [Card(uuid: "1", title: "Italy"),
            Card(uuid: "2", title: "England"),
            Card(uuid: "3", title: "Portugal")]
        
        RowView(delegate: MockRowViewDelegate(), cards: cards, width: 100, horizontalSpacing: 20)
    }
}

struct MockRowViewDelegate: RowViewDelegate {
    func resetList() {
        // no-op
    }
    
    func didTapCard(_ card: Card) {
        // no-op
    }
}
