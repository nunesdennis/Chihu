//
//  GridContentView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//

import SwiftUI

protocol GridContentViewDelegate {
    func shouldLoadMore() -> Bool
    func loadMore()
    func didTapCard(_ card: Card)
    func resetList()
}

extension GridContentView: RowViewDelegate {
    func didTapCard(_ card: Card) {
        delegate.didTapCard(card)
    }
    
    func resetList() {
        delegate.resetList()
    }
}

struct GridContentView: View {
    @Environment(\.isSearching) var isSearching
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let delegate: GridContentViewDelegate
    var itemPerRow: CGFloat {
        let device = UIDevice.current
        if device.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
            return 3
        } else {
            return 6
        }
    }
    
    let horizontalSpacing: CGFloat = 8
    var cards: [Card]
    
    var body: some View {
        if cards.isEmpty {
            EmptyView()
        } else {
            hGrid
                .onChange(of: isSearching) {
                    if !isSearching {
                        delegate.resetList()
                    }
                }
        }
    }
    
    var hGrid: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .zero) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { i, _ in
                        if i % Int(itemPerRow) == 0 {
                            buildView(rowIndex: i, geometry: geometry)
                        }
                    }
                    if delegate.shouldLoadMore() {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1)
                            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: 40, alignment: .bottom)
                            .onAppear {
                                delegate.loadMore()
                            }
                    }
                }
            }.coordinateSpace(name: "scroll")
        }
    }
    
    func buildView(rowIndex: Int, geometry: GeometryProxy) -> RowView? {
        var rowCards = [Card]()
        for itemIndex in 0..<Int(itemPerRow) {
            if rowIndex + itemIndex < cards.count {
                rowCards.append(cards[rowIndex + itemIndex])
            }
        }
        if !rowCards.isEmpty {
            return RowView(delegate: self, cards: rowCards, width: getWidth(geometry: geometry), horizontalSpacing: horizontalSpacing)
        }
        
        return nil
    }
    
    func getWidth(geometry: GeometryProxy) -> CGFloat {
        let width: CGFloat = (geometry.size.width - horizontalSpacing * (itemPerRow + 1)) / itemPerRow
        return width
    }
}

struct GridContentView_Previews: PreviewProvider {
    static var previews: some View {
        let cards = [Card(uuid: "1", title: "Italy temporada 1, filme 3, a vingaça de todo mundo"),
                        Card(uuid: "2", title: "England"),
                        Card(uuid: "3", title: "Portugal"),
                        Card(uuid: "4", title: "Belgium"),
                        Card(uuid: "5", title: "Germany"),
                        Card(uuid: "6", title: "Mexico"),
                        Card(uuid: "7", title: "Canada"),
                        Card(uuid: "8", title: "Italy"),
                        Card(uuid: "9", title: "England"),
                        Card(uuid: "10", title: "Portugal"),
                        Card(uuid: "11", title: "Belgium"),
                        Card(uuid: "12", title: "Germany"),
                        Card(uuid: "13", title: "Mexico"),
                        Card(uuid: "14", title: "Canada"),
                        Card(uuid: "15", title: "England"),
                        Card(uuid: "16", title: "Portugal"),
                        Card(uuid: "17", title: "Belgium"),
                        Card(uuid: "18", title: "Germany"),
                        Card(uuid: "19", title: "Mexico"),
                        Card(uuid: "20", title: "Canada")]
        
        GridContentView(delegate: MockDelegate(), cards: cards)
    }
}

struct MockDelegate: GridContentViewDelegate {
    func resetList() {
        //no-op
    }
    
    func didTapCard(_ card: Card) {
        //no-op
    }
    
    func shouldLoadMore() -> Bool {
        //no-op
        false
    }
    
    func loadMore() {
        //no-op
    }
}
