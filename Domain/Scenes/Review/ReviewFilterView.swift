//
//  ReviewFilterView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 16/09/24.
//

import SwiftUI

protocol ReviewFilterViewDelegate {
    func didPressVisibilityButton(_ visibility: Visibility)
    func didPressShelfTypeButton(_ shelftype: ShelfType)
    func didPressCrosspostSwitch(_ shouldCrosspost: Bool)
}

struct ReviewFilterView: View {
    @State var isVisibilityExpanded: Bool = false
    @State var isShelfTypeExpanded: Bool = false
    
    @Binding var reviewTypeSelected: ReviewType
    @Binding var selectedVisibility: Int
    @Binding var selectedShelfType: Int
    @Binding var shouldCrosspost: Bool
    
    var delegate: ReviewFilterViewDelegate
    
    let visibilityList: [Visibility]
    let shelfTypeList: [ShelfType]
    
    init(reviewTypeSelected: Binding<ReviewType>,
         selectedVisibility: Binding<Int>,
         selectedShelfType: Binding<Int>,
         shouldCrosspost: Binding<Bool>,
         visibilityList: [Visibility] = [.public, .followersOnly, .mentionedOnly],
         shelfTypeList: [ShelfType] = [.complete, .wishlist, .progress, .dropped],
         delegate: ReviewFilterViewDelegate) {
        _reviewTypeSelected = reviewTypeSelected
        _selectedVisibility = selectedVisibility
        _selectedShelfType = selectedShelfType
        _shouldCrosspost = shouldCrosspost
        self.visibilityList = visibilityList
        self.shelfTypeList = shelfTypeList
        self.delegate = delegate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch reviewTypeSelected {
            case .progressNote:
                visibilityFilter()
                crosspostFilter()
            case .review:
                crosspostFilter()
            default:
                stateFilter()
                visibilityFilter()
                crosspostFilter()
            }
        }
        .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
    }
    
    func stateFilter() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("State")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(shelfTypeList[selectedShelfType].shelfTypeButtonName()) {
                    withAnimation {
                        isShelfTypeExpanded = !isShelfTypeExpanded
                    }
                }
                .buttonStyle(.bordered)
                .tint(.filterButtonSelectedColor)
            }
            if isShelfTypeExpanded {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(shelfTypeList.indices, id: \.self) { index in
                        Button(shelfTypeList[index].shelfTypeButtonName()) {
                            selectedShelfType = index
                            delegate.didPressShelfTypeButton(shelfTypeList[index])
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonShelfTypeColor(index: index))
                    }
                }
            }
        }
    }
    
    func visibilityFilter() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Visibility")
                    .font(.title3)
                    .bold()
                    .frame(alignment: .leading)
                Spacer()
                Button(visibilityList[selectedVisibility].visibilityButtonName()) {
                    withAnimation {
                        isVisibilityExpanded = !isVisibilityExpanded
                    }
                }
                .buttonStyle(.bordered)
                .tint(.filterButtonSelectedColor)
            }
            if isVisibilityExpanded {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(visibilityList.indices, id: \.self) { index in
                        Button(visibilityList[index].visibilityButtonName()) {
                            selectedVisibility = index
                            delegate.didPressVisibilityButton(visibilityList[index])
                        }
                        .buttonStyle(.bordered)
                        .tint(buttonVisibilityColor(index: index))
                    }
                }
            }
        }
    }
    
    func crosspostFilter() -> some View {
        HStack {
            Text("Crosspost to timeline")
                .font(.title3)
                .bold()
                .frame(alignment: .leading)
            Spacer()
            Toggle(buttonCrosspostText(shouldCrosspost), isOn: $shouldCrosspost)
                .toggleStyle(.button)
                .tint(buttonCrosspostColor(shouldCrosspost))
                .onChange(of: shouldCrosspost) {
                    delegate.didPressCrosspostSwitch(shouldCrosspost)
                }
        }
    }
    
    func buttonShelfTypeColor(index: Int) -> Color {
        index == selectedShelfType ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonVisibilityColor(index: Int) -> Color {
        index == selectedVisibility ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
    
    func buttonCrosspostText(_ shouldCrosspost: Bool) -> String {
        shouldCrosspost ? "On" : "Off"
    }
    
    func buttonCrosspostColor(_ shouldCrosspost: Bool) -> Color {
        shouldCrosspost ? .filterButtonSelectedColor : .filterButtonNotSelectedColor
    }
}
