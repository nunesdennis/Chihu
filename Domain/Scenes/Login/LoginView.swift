//
//  LoginView.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//  
//
import SwiftUI
import SafariServices

protocol LoginDisplayLogic {
    func displayRegisterSuccess(model: AppRegistrationResponse)
    func displaySuccess()
    func display(error: Error)
}

extension LoginView: LoginDisplayLogic {
    func displaySuccess() {
        DispatchQueue.main.async {
            dataStore.state = .success
        }
    }
    
    func displayRegisterSuccess(model: AppRegistrationResponse) {
        DispatchQueue.main.async {
            EnvironmentKeys.saveCustomKeys(from: model)
            let yourServer = "Your Server"
            if dataStore.registeredServerList.first?.name == yourServer {
                dataStore.registeredServerList[0] = .init(name: yourServer, urlString: dataStore.inputText, language: nil)
            } else {
                dataStore.registeredServerList.insert(.init(name: yourServer, urlString: dataStore.inputText, language: nil), at: 0)
            }
            dataStore.state = .useAnotherServer
        }
    }
    
    func display(error: Error) {
        DispatchQueue.main.async {
            dataStore.state = .error(error)
        }
    }
    
    func login(withAuthCode authCodeReceived: String = "") {
        dataStore.state = .loading
        guard !authCodeInputText.isEmpty || !authCodeReceived.isEmpty else {
            dataStore.state = .error(ChihuError.authCodeMissing)
            return
        }
        
        let baseUrl = !instanceInputText.isEmpty ? instanceInputText : LoginConstants.eggplantUrl
        let authCode = !authCodeInputText.isEmpty ? authCodeInputText : authCodeReceived
        
        guard let requestBody = Login.Token.Request.TokenRequestBody(authCode: authCode, instanceBaseURL: baseUrl) else {
            dataStore.state = .error(ChihuError.appAccessKeysAreWrong)
            return
        }
        
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        let request = Login.Token.Request(instanceBaseURL: baseUrl, body: requestBody)
        interactor.load(request: request)
    }
    
    func registerLocally() {
        let request = AppRegistrationRequest(body: .init(), instanceBaseURL: dataStore.inputText)
        dataStore.state = .loading
        guard let interactor else {
            dataStore.state = .error(ChihuError.codeError)
            return
        }
        
        interactor.register(request: request)
    }
}

extension LoginView {
    func registeredServerCell(_ server: RegisteredServer) -> some View {
        Button {
            self.instanceInputText = server.urlString
            authorize(with: server.urlString)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(server.name)
                        .multilineTextAlignment(.leading)
                    if let language = server.language {
                        Text(language)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.chihuGray)
                    }
                }
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.loginRowBackgroundColor)
        .foregroundColor(Color.chihuBlack)
    }
}

struct RegisteredServer: Identifiable {
    var id = UUID()
    let name: String
    let urlString: String
    let language: String?
}

enum LoginConstants {
    static let eggplantUrl = "https://eggplant.place"
    static let neodbUrl = "https://neodb.social"
    static let reviewDB = "https://reviewdb.app"
    static let minreol = "https://minreol.dk"
    static let dbCasually = "https://db.casually.cat"
    static let neodbKevga = "https://neodb.kevga.de"
    static let fantastika = "https://fantastika.social"
    static let neodbDeadvey = "https://neodb.deadvey.com"
}

struct LoginView: View {
    var interactor: LoginBusinessLogic?
    
    @Environment(\.openURL) var openURL
    @ObservedObject var dataStore = LoginDataStore()
    @State var instanceInputText: String = ""
    @State var authCodeInputText: String = ""
    @FocusState private var fieldIsFocused: Bool
    
    var body: some View {
        ZStack {
            HeaderLoginView()
            VStack {
                Spacer()
                    .frame(height: 300)
                bottomView
                Spacer()
            }
        }
        .background(Color.loginBackgroundColor)
    }
    
    var bottomView: some View {
        VStack {
            switch dataStore.state {
            case .firstScreen:
                Button("Sign up or Login") {
                    self.instanceInputText = LoginConstants.eggplantUrl
                    authorize(with: LoginConstants.eggplantUrl)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.loginPrimaryBackgroundColor)
                Button("Use another server") {
                    dataStore.state = .useAnotherServer
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.loginSecondaryBackgroundColor)
            case .useAnotherServer:
                Text("Registered Servers")
                    .font(.title3)
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(dataStore.registeredServerList) { server in
                            registeredServerCell(server)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(EdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20))
            case .success:
                Text("Success")
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
            case .registerLocally:
                Text("Register new server locally")
                    .font(.title3)
                textFieldView()
                Button("Register locally") {
                    registerLocally()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.loginPrimaryBackgroundColor)
            default:
                errorView(dataStore.state)
            }
            if dataStore.state != .loading && dataStore.state != .firstScreen {
                HStack(spacing: 8) {
                    Button("Restart") {
                        restart()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.loginSecondaryBackgroundColor)
                    if dataStore.state == .useAnotherServer {
                        Button("Add new") {
                            dataStore.state = .registerLocally
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.loginSecondaryBackgroundColor)
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onOpenURL { incomingURL in
            handleIncomingURL(incomingURL)
        }
        .fullScreenCover(isPresented: $dataStore.openWebView) {
            SafariWebView(url: dataStore.authenticationUrl)
                .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    fieldIsFocused = false
                }
        )
    }
    
    private func textFieldView() -> some View {
        VStack {
            TextField(LoginConstants.eggplantUrl, text: $dataStore.inputText, axis: .vertical)
                .lineLimit(1, reservesSpace: true)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.loginNewServerUrlBackgroundColor))
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
    }
    
    private func errorView(_ errorState: LoginState) -> some View {
        switch errorState {
        case .error(let errorReceived):
            if let apiError = errorReceived as? ChihuError {
                if case ChihuError.api(error: let error) = apiError {
                    return ErrorView(error: error)
                } else {
                    return ErrorView(error: apiError)
                }
            } else if let _ = errorReceived as? KeychainManager.KeychainError {
                return ErrorView(error: ChihuError.keychain)
            }
            return ErrorView(error: errorReceived)
        default:
            return ErrorView(error: ChihuError.unknown)
        }
    }
    
    private func authorize(with urlString: String) {
        if let url = AuthorizeEndpoint(urlString).url {
            dataStore.authenticationUrl = url
            dataStore.openWebView = true
        } else {
            dataStore.state = .error(ChihuError.invalidURL)
        }
    }
    
    private func pickAnotherServer() {
        instanceInputText = ""
        authCodeInputText = ""
        dataStore.state = .useAnotherServer
    }
    
    private func restart() {
        instanceInputText = ""
        authCodeInputText = ""
        dataStore.state = .firstScreen
    }
    
    /// Handles the incoming URL and performs validations before acknowledging.
    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        guard let action = components.host, action == "chihu.app" else {
            print("Unknown URL, we can't handle this one!")
            return
        }

        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("Recipe name not found")
            return
        }

        login(withAuthCode: code)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        return LoginView()
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
