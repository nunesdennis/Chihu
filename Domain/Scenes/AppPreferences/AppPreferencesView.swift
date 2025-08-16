//
//  AppPreferencesView.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 20/07/25.
//

import SwiftUI

struct PreferenceCell: Identifiable {
    var id = UUID()
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    init(title: LocalizedStringKey, description: LocalizedStringKey) {
        self.title = title
        self.description = description
    }
}

struct AppPreferencesView: View {
    
    @State var hideNeoDBscore: Bool
    @State var hideYourScore: Bool
    @State var isShelfTypeExpanded = false
    @State var isSearchCategoryExpanded: Bool = false
    @State var defaultShelfType: Int
    @State var defaultSearchCategory: Int
    
    let neoDBScoreModel = PreferenceCell(title: "NeoDB 🧩", description: "Hide NeoDB scores from under cards and review screen.")
    let yourScoreModel = PreferenceCell(title: "Your Scores", description: "Hide your scores from under cards.")
    
    let searchCategoryList: [CategorySources] = FilterView.makeCategorySourceList()
    
    let shelfTypeList: [ShelfType] = [
        .complete, .wishlist, .progress, .dropped
    ]
    
    let threeColumns = [
      GridItem(.flexible(minimum: 125)),
      GridItem(.flexible(minimum: 90)),
      GridItem(.flexible(minimum: 90))
    ]
    
    init() {
        hideYourScore = !UserSettings.shared.showYourScore
        hideNeoDBscore = !UserSettings.shared.showNeoDBscore
        
        let defaultShelfTypeString = UserSettings.shared.defaultShelfType
        let defaultSearchCategoryString = UserSettings.shared.defaultSearchCategory
        defaultShelfType = shelfTypeList.firstIndex(of: ShelfType(rawValue: defaultShelfTypeString) ?? .progress) ?? 0
        defaultSearchCategory = searchCategoryList.firstIndex(where: { $0.category.itemCategory.rawValue == defaultSearchCategoryString }) ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hide preferences section
                    Text("Hide preferences")
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    VStack(alignment: .leading, spacing: 0) {
                        textCell(preferenceCell: neoDBScoreModel, isOn: $hideNeoDBscore)
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        Divider()
                        textCell(preferenceCell: yourScoreModel, isOn: $hideYourScore)
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                    .background(Color.appPreferencesViewRowBackgroundColor)
                    .padding(.horizontal, 8)
                    .cornerRadius(16)
                    
                    // Default Filters section
                    Text("Default Filters")
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        
                    VStack(spacing: 0) {
                        filterSearchCategoryView
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        Divider()
                        filterShelfTypeView
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                    .background(Color.appPreferencesViewRowBackgroundColor)
                    .padding(.horizontal, 8)
                    .cornerRadius(16)
                }
            }
            .toolbarBackground(Color.appPreferencesViewBackgroundColor, for: .navigationBar)
            .background(Color.appPreferencesViewBackgroundColor)
            .navigationTitle("App Preferences")
            .onChange(of: hideYourScore) {
                UserSettings.shared.showYourScore = !hideYourScore
            }
            .onChange(of: hideNeoDBscore) {
                UserSettings.shared.showNeoDBscore = !hideNeoDBscore
            }
            .onChange(of: defaultShelfType) {
                UserSettings.shared.defaultShelfType = shelfTypeList[defaultShelfType].rawValue
            }
            .onChange(of: defaultSearchCategory) {
                UserSettings.shared.defaultSearchCategory = searchCategoryList[defaultSearchCategory].category.rawValue
            }
        }
    }
    
    func textCell(preferenceCell: PreferenceCell, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(preferenceCell.title)
                .multilineTextAlignment(.leading)
            Toggle(isOn: isOn) {
                Text(preferenceCell.description)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.chihuGray)
            }
            .toggleStyle(SwitchToggleStyle(tint: .chihuGreen))
        }
    }
    
    var filterSearchCategoryView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Search Category")
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(searchCategoryList[defaultSearchCategory].category.buttonName()) {
                    withAnimation {
                        isSearchCategoryExpanded = !isSearchCategoryExpanded
                    }
                }
                .buttonStyle(.bordered)
                .tint(.filterButtonSelectedColor)
            }
            if isSearchCategoryExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(searchCategoryList.indices, id: \.self) { index in
                        Button(searchCategoryList[index].category.buttonName()) {
                            defaultSearchCategory = index
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonCategoryColor(index: index))
                    }
                }
            }
        }
    }
    
    
    var filterShelfTypeView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Shelf type")
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(shelfTypeList[defaultShelfType].shelfTypeButtonName()) {
                        withAnimation {
                            isShelfTypeExpanded.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.filterButtonSelectedColor)
            }
            if isShelfTypeExpanded {
                LazyVGrid(columns: threeColumns) {
                    ForEach(shelfTypeList.indices, id: \.self) { index in
                        Button(shelfTypeList[index].shelfTypeButtonName()) {
                            defaultShelfType = index
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonShelfTypeColor(index: index))
                    }
                }
            }
        }
    }
    
    func buttonShelfTypeColor(index: Int) -> Color {
        index == defaultShelfType ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
        
    func buttonCategoryColor(index: Int) -> Color {
        index == defaultSearchCategory ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}

#Preview {
    AppPreferencesView()
}
