//
//  MainView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//

import Foundation
import SwiftUI

final class MainDataStore: ObservableObject {
    var selectedItem: ItemViewModel?
    var reviewDataStore = ReviewDataStore()
    
    func createNewReviewDataStore() -> ReviewDataStore {
        if selectedItem?.id == reviewDataStore.item?.id {
            return reviewDataStore
        }
        self.reviewDataStore = ReviewDataStore()
        
        return reviewDataStore
    }
}

struct MainView: View {
    
    @State private var tabTapped = false
    @State private var openReview = false
    @State var selectedTab = 0
    @StateObject var userSettings = UserSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    
    let dataStore = MainDataStore()
    let shelfListDataStore = ShelfListDataStore()
    let searchDataStore = SearchDataStore()
    let timelineDataStore = TimelineDataStore()
    let notificationsDataStore = NotificationsDataStore()
    let settingsDataStore = SettingsDataStore()
    
    var body: some View {
        TabView(selection: $selectedTab.onUpdate {
            if selectedTab == 1 {
                tabTapped = true
            }
        }) {
            SearchView(dataStore: searchDataStore).configureView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .toolbarBackground(Color.tabbarBackgroundColor, for: .tabBar)
                .tag(0)
            TimelineView(tabTapped: $tabTapped, dataStore: timelineDataStore).configureView()
                .tabItem {
                    Label("Feed", systemImage: "person.2.fill")
                }
                .toolbarBackground(Color.tabbarBackgroundColor, for: .tabBar)
                .tag(1)
            NotificationsView(tabTapped: $tabTapped, dataStore: notificationsDataStore).configureView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .toolbarBackground(Color.tabbarBackgroundColor, for: .tabBar)
                .tag(2)
            ShelfListFilterView(dataStore: shelfListDataStore).configureView()
                .tabItem {
                    Label("Shelf", systemImage: "rectangle.split.3x1")
                }
                .toolbarBackground(Color.tabbarBackgroundColor, for: .tabBar)
                .tag(3)
            SettingsView(dataStore: settingsDataStore).configureView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .toolbarBackground(Color.tabbarBackgroundColor, for: .tabBar)
                .tag(4)
        }
        .fullScreenCover(isPresented: $userSettings.shouldShowLogin) {
            LoginView().configureView()
        }
        .fullScreenCover(isPresented: $openReview) {
            if let item = dataStore.selectedItem {
                ReviewView(item: item, dataStore: dataStore.createNewReviewDataStore())
                    .configureView()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                userSettings.clearAllAppCache()
            }
        }
        .environment(\.reviewItem, ShowReviewAction(action: { type in
            if case .review(let item) = type {
                dataStore.selectedItem = item
                openReview = true
            }
        }))
        .tint(.tabbarButtonColor)
        .colorScheme()
    }
}

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}
