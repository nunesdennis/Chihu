//
//  FilterView.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/09/24.
//

import SwiftUI

enum ItemCategory: String, Codable, CaseIterable {
    case allItems
    case book
    case movie
    case tv
    case tvSeason
    case tvEpisode
    case music
    case game
    case podcast
    case performance
    case performanceProduction
    case fanfic
    case exhibition
    case collection
    case unknown
    
    enum shelfAvailable: String, CaseIterable, Codable {
        case allItems
        case book
        case movie
        case tv
        case music
        case game
        case podcast
        case performance

        var itemCategory: ItemCategory? {
            switch self {
            case .allItems: return .allItems
            case .book: return .book
            case .movie: return .movie
            case .tv: return .tv
            case .music: return .music
            case .game: return .game
            case .podcast: return .podcast
            case .performance: return .performance
            }
        }
    }

    enum searchable: String, CaseIterable, Codable {
        case allItems
        case book
        case movie
        case tv
        case movieAndTv = "movie,tv"
        case music
        case game
        case podcast
        case performance
        
        var itemCategory: ItemCategory {
            switch self {
            case .allItems: return .allItems
            case .movie: return .movie
            case .tv: return .tv
            case .book: return .book
            case .music: return .music
            case .game: return .game
            case .podcast: return .podcast
            case .performance: return .performance
            default: return .unknown
            }
        }
        
        func buttonName() -> LocalizedStringKey {
            self.itemCategory.buttonName()
        }
    }
    
    enum progressNoteType: String, Codable {
        case page
        case chapter
        case percentage
        case part
        case timestamp
        case episode
        case cycle
        case track
        case none
        
        func buttonName() -> LocalizedStringKey {
            switch self {
            case .page: return "Page"
            case .chapter: return "Chapter"
            case .percentage: return "Percentage"
            case .part: return "Part"
            case .timestamp: return "Timestamp"
            case .episode: return "Episode"
            case .cycle: return "Cycle"
            case .track: return "Track"
            case .none: return "Progress Type (optional)"
            }
        }
    }
    
    var availableProgressNoteTypes: [progressNoteType] {
        switch self {
        case .book: return [.none, .page, .chapter, .percentage]
        case .movie: return [.none, .part, .timestamp, .percentage]
        case .tv, .tvSeason, .tvEpisode: return [.none, .part, .episode, .percentage]
        case .game: return [.none, .cycle]
        case .podcast: return [.none, .episode]
        default: return []
        }
    }
    
    var itemClass: any ItemProtocol.Type {
        switch self {
        case .tv, .tvSeason, .tvEpisode:
            return TVShowSchema.self
        default:
            return ItemSchema.self
        }
    }
    
    func buttonName() -> LocalizedStringKey {
        switch self {
        case .allItems: return "All"
        case .book: return "Book"
        case .movie: return "Movie"
        case .tv, .tvSeason, .tvEpisode: return "TV"
        case .music: return "Music"
        case .game: return "Game"
        case .podcast: return "Podcast"
        case .performance, .performanceProduction: return "Performance"
        case .fanfic: return "Fanfic"
        case .exhibition: return "Exhibition"
        case .collection: return "Collection"
        case .unknown: return "Unknown"
        }
    }
}

enum ItemSource: LocalizedStringKey, Codable {
    case instance = "Server"
    case tmdb = "TMDB"
    case googleBooks = "Google Books"
    case podcastIndex = "Podcast Index"
    
    static func from(string: String) -> ItemSource {
        switch string {
        case "Server":
            return .instance
        case "TMDB":
            return .tmdb
        case "Google Books":
            return .googleBooks
        case "Podcast Index":
            return .podcastIndex
        default:
            return .instance
        }
    }
}

struct CategorySources: Identifiable {
    let id = UUID()
    let category: ItemCategory.searchable
    let sourceList: [ItemSource]
    
    init(category: ItemCategory.searchable, sourceList: [ItemSource] = [.instance]) {
        self.category = category
        self.sourceList = sourceList
    }
}

struct FilterView: View {
    @StateObject var userSettings = UserSettings.shared
    
    @State var isSourceExpanded: Bool = false
    @State var isCategoryExpanded: Bool = false
    
    @Binding var category: ItemCategory
    @Binding var source: ItemSource
    
    var selectedCategory: Int {
        categorySourceList.firstIndex {
            $0.category.itemCategory == category
        } ?? 0
    }
    var selectedSource: Int {
        categorySourceList[selectedCategory].sourceList.firstIndex {
            $0 == source
        } ?? 0
    }
    
    var categorySourceList: [CategorySources] = FilterView.makeCategorySourceList()
    
    static func makeCategorySourceList() -> [CategorySources] {
        var list = [
            CategorySources(category: .movie, sourceList: [.tmdb, .instance]),
            CategorySources(category: .tv, sourceList: [.tmdb, .instance]),
            CategorySources(category: .book, sourceList: [.googleBooks, .instance]),
            CategorySources(category: .music),
            CategorySources(category: .game),
            CategorySources(category: .podcast, sourceList: [.podcastIndex, .instance]),
            CategorySources(category: .performance)
        ]
        
        if let hiddenCategories = UserSettings.shared.userPreference?.hiddenCategories {
            hiddenCategories.forEach { categoryString in
                let category = ItemCategory.searchable(rawValue: categoryString)
                list.removeAll { element in
                    element.category == category
                }
            }
        }
        
        return list
    }
    
    let threeColumns = [
      GridItem(.flexible(minimum: 125)),
      GridItem(.flexible(minimum: 90)),
      GridItem(.flexible(minimum: 90))
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Categories")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(categorySourceList[selectedCategory].category.buttonName()) {
                        withAnimation {
                            isCategoryExpanded = !isCategoryExpanded
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.filterButtonSelectedColor)
            }
            if isCategoryExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(categorySourceList.indices, id: \.self) { index in
                        Button(categorySourceList[index].category.buttonName()) {
                            category = categorySourceList[index].category.itemCategory
                            source = categorySourceList[index].sourceList[0]
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonCategoryColor(index: index))
                    }
                }
            }
            HStack {
                Text("Sources")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(categorySourceList[selectedCategory].sourceList[selectedSource].rawValue) {
                        withAnimation {
                            isSourceExpanded = !isSourceExpanded
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.filterButtonSelectedColor)
            }
            if isSourceExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(categorySourceList[selectedCategory].sourceList.indices, id: \.self) { index in
                        Button(categorySourceList[selectedCategory].sourceList[index].rawValue) {
                            source = categorySourceList[selectedCategory].sourceList[index]
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonSourceColor(index: index))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16))
    }
    
    func buttonCategoryColor(index: Int) -> Color {
        index == selectedCategory ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonSourceColor(index: Int) -> Color {
        index == selectedSource ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}
