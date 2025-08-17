//
//  SettingsView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/09/24.
//

import SwiftUI

protocol ProfileDisplayLogic {
    func display(viewModel: Profile.Load.ViewModel)
    func displayAvatarUpdate(viewModel: Profile.Load.ViewModel)
    func displayError(_ error: Error)
}

extension SettingsView: ProfileDisplayLogic {
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.errorMessage = LocalizedStringKey(ChihuError.api(error: error).localizedDescription)
            dataStore.showError = true
        }
    }
    
    func display(viewModel: Profile.Load.ViewModel) {
        userSettings.profileInfo = viewModel
        dataStore.profileViewModel = viewModel
        dataStore.state = .loaded
    }
    
    func displayAvatarUpdate(viewModel: Profile.Load.ViewModel) {
        userSettings.profileInfo = viewModel
        dataStore.profileViewModel = viewModel
        dataStore.alertMessage = LocalizedStringKey("ok")
        dataStore.showAlert = true
    }
    
    func fetch() {
        if let profileInfo = userSettings.profileInfo {
            dataStore.profileViewModel = profileInfo
            dataStore.state = .loaded
            
            return
        }
        
        let requestUser = Profile.Load.Request()
        interactor?.load(request: requestUser)
    }
}

struct SettingsView: View {
    var interactor: ProfileBusinessLogic?
    
    @Environment(\.openURL) var openURL
    @Environment(\.showToast) private var showToast
    @StateObject var userSettings = UserSettings.shared
    
    @ObservedObject var dataStore: SettingsDataStore
    
    init(dataStore: SettingsDataStore = SettingsDataStore()) {
        self.dataStore = dataStore
    }
    
    let settings: Array<Setting> = [
        Setting(option: .supportDev, color: .chihuYellow, imageName: "dollarsign.circle.fill"),
        Setting(option: .aboutTheApp, color: .chihuBlue, imageName: "info.circle.fill"),
        Setting(option: .gratitude, color: .chihuRed, imageName: "heart.circle.fill"),
        Setting(option: .contactTheDev, color: .chihuGray, imageName: "person.circle.fill"),
        Setting(option: .themes, color: .chihuGreen, imageName: "paintbrush"),
        Setting(option: .appPreferences, color: .chihuGray, imageName: "gear")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                if let viewModel = dataStore.profileViewModel {
                    Section {
                        ProfileCell(viewModel: viewModel, interactor: interactor, dataStore: dataStore)
                    }
                    .listRowBackground(Color.settingsRowBackgroundColor)
                }
                
                Section {
                    ForEach(settings, id: \.self) { setting in
                        if isWebLink(from: setting.option) {
                            Button {
                                openURL(getLink(from: setting.option))
                            } label: {
                                cell(from: setting)
                            }
                        } else {
                            NavigationLink(destination: RootSettingView(viewToDisplay: setting.option)) {
                                cell(from: setting)
                            }
                        }
                    }
                }
                .listRowBackground(Color.settingsRowBackgroundColor)
                Section {
                    Button("Delete Account") {
                        if let url = deleteAccountURL() {
                            openURL(url)
                        } else if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines),
                                  let baseUrl = URL(string: baseUrlString) {
                            openURL(baseUrl)
                        }
                    }
                    .tint(Color.chihuRed)
                }
                .listRowBackground(Color.settingsRowBackgroundColor)
                Section {
                    Button("Logout") {
                        logout()
                    }
                    .tint(Color.chihuRed)
                }
                .listRowBackground(Color.settingsRowBackgroundColor)
            }
            .background(Color.settingsBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .task {
                fetch()
            }
            .onChange(of: dataStore.showAlert) {
                showToast(.success(nil, dataStore.alertMessage))
            }
            .onChange(of: dataStore.showError) {
                showToast(.failure(nil, dataStore.errorMessage))
            }
        }
    }
    
    func getLink(from option: SettingsOptions) -> URL {
        option.url()!
    }
    
    func isWebLink(from option: SettingsOptions) -> Bool {
        switch option {
        case .contactTheDev:
            true
        default:
            false
        }
    }
    
    func cell(from setting: Setting) -> some View {
        HStack {
            SettingImage(color: setting.color, imageName: setting.imageName)
            Text(setting.option.rawValue)
                .tint(Color.primary)
        }
    }
    
    func deleteAccountURL() -> URL? {
        if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines) {
            let accountUrl = baseUrlString + "/account/info"
            return URL(string: accountUrl)
        }
        
        return nil
    }
    
    func logout() {
        dataStore.profileViewModel = nil
        try? UserSettings.shared.logout()
    }
}

#Preview {
    SettingsView()
}
